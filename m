From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] DefineSimpleCache macro problem
Date: Thu, 13 May 2004 12:45:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040513104552.GT22052@suse.de>
References: <20040513082245.GM22052@suse.de> <16547.16795.844328.645694@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BODiu-0003Al-6t
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 03:45:56 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BODit-0001A2-GU
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 03:45:55 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16547.16795.844328.645694@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, May 13, 2004 at 07:36:27PM +1000, Neil Brown wrote:
> That would be wrong.  Always returning an entry (possibly non-VALID)
> - except on kmalloc failure - is a design feature.

Does this mean I can eat all your memory by flooding your NFS server
with NULL calls from bogus addresses? That would be bad.

> Can you help understand more about your particular problem?
> Why do you think that svc_export_lookup returning a non-VALID entry
> causes a problem.
> It is only called with "set" == 0 in exp_get_by_name, and
> exp_get_by_name will only return it to the caller it is VALID.
> So I cannot figure out what the real problem is yet.

The problem is that somewhere somehow an invalid entry is created,
which remains in the cache and the flags don't get updated.

Here's a trace of mountd, after reboot with a fresh slate (i.e. 
/proc/net/rpc/nfsd.export/contents is empty). The mount attempts
are pretty close together; this happens reproduceably if the client
is the automounter using /net/<hostname>

open("/proc/net/rpc/nfsd.export/channel", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 6
write(6, "someclient.suse.de / 2147483647 32 65534 65534 2053 \n", 50) = 50
open("/proc/net/rpc/nfsd.fh/channel", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 6
write(6, "someclient.suse.de 0 \\x0008000502000000 2147483647 / \n", 51) = 51
open("/proc/net/rpc/nfsd.export/channel", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 6
write(6, "someclient.suse.de /boot 2147483647 32 65534 65534 2049 \n", 54) = 54
open("/proc/net/rpc/nfsd.fh/channel", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 6
write(6, "someclient.suse.de 0 \\x0008000102000000 2147483647 /boot \n", 55) = -1 ENOENT (No such file or directory)
open("/proc/net/rpc/nfsd.fh/channel", O_WRONLY) = 6
open("/proc/net/rpc/nfsd.export/channel", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 6
write(6, "someclient.suse.de /home 2147483647 32 65534 65534 2054 \n", 54) = 54
open("/proc/net/rpc/nfsd.fh/channel", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 6
write(6, "someclient.suse.de 0 \\x0008000602000000 2147483647 /home \n", 55) = -1 ENOENT (No such file or directory)

As you can see, the attempt to write to nfsd.fh fails with ENOENT.

Here's a snippet from syslog:

May 10 12:54:52 testnfs kernel: nfsd: exp_rootfh(/ [c7dd2280] appserv.suse.de:sda5/2)
...
May 10 12:54:52 testnfs kernel: svc_expkey_lookup called
May 10 12:54:52 testnfs kernel: cache_check:67: item=c54c09c0
May 10 12:54:52 testnfs kernel: cache_check:80: rv=0
				^^^ we repeatedly call svc_expkey_lookup,
				^^^ I see 2 or 3 different item pointers
...
May 10 12:54:52 testnfs kernel: svc_export_lookup called
May 10 12:54:52 testnfs kernel: cache_init:40: item=c54c0900
May 10 12:54:52 testnfs kernel: exp_get_by_name:589: exp=c54c0900 flags=8
				^^^ here we get a fresh entry but don't init it
				^^^ not sure who called exp_get_by_name here
May 10 12:54:52 testnfs kernel: cache_check:67: item=c54c0900
May 10 12:54:52 testnfs kernel: cache_check:71: flags=0x8 expiry=1084186612 now=1084186492
May 10 12:54:52 testnfs kernel: cache_check:86: rv=-11
May 10 12:54:52 testnfs kernel: Want update, refage=120, age=0
May 10 12:54:52 testnfs kernel: cache_fresh:130: item=c54c0900, expiry=1084186612
...
May 10 12:54:52 testnfs kernel: svc_export_parse:402: an_int=32
May 10 12:54:52 testnfs kernel: svc_export_parse:425: err=0
May 10 12:54:52 testnfs kernel: svc_export_lookup called
May 10 12:54:52 testnfs kernel: svc_export_update:494: new=c54c0900 flags=b
				^^^ and by now the item has turned bad
				^^^ (HASHED,VALID,NEGATIVE)
May 10 12:54:52 testnfs kernel: cache_fresh:130: item=c54c0900, expiry=2147483647
May 10 12:54:52 testnfs kernel: svc_export_parse:428: expp=c54c0900 flags=b
May 10 12:54:52 testnfs kernel: svc_export_parse:440: err=0
May 10 12:54:52 testnfs kernel: found domain someclient.suse.de
May 10 12:54:52 testnfs kernel: found fsidtype 0
May 10 12:54:52 testnfs kernel: found fsid length 8
May 10 12:54:52 testnfs kernel: Path seems to be </boot>
May 10 12:54:52 testnfs kernel: Found the path /boot
...

I haven't yet figured out exactly what happens, but _something_ calls
exp_get_by_name for /boot prior to mount's call. This leaves an invalid
item in the cache, and svc_export_update doesn't fix the flags.

These bad export entries are visible in
/proc/net/rpc/nfsd.export/contents; they're shown as

# someclient.suse.de ....

> Also, are you running with the nfsd filesystem mounted on
> /proc/fs/nfsd (or /proc/fs/nfs) or with it unmounted?

The nfsd file system is not mounted, but I think this shouldn't 
make a difference.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
