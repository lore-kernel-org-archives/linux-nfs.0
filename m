From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: take away nfs write permissions instantly
Date: Fri, 21 Jun 2002 15:13:24 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15634.46580.599919.518166@notabene.cse.unsw.edu.au>
References: <3D11B0FF.8030008@psi.ch>
	<15634.38625.279876.874050@notabene.cse.unsw.edu.au>
	<3D12A1CD.8040502@psi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17LGiy-0006kd-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Jun 2002 22:12:46 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <rene.kapeller@psi.ch>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 21 Jun 2002 15:12:35 +1000
To: Kapeller Rene PSI <rene.kapeller@psi.ch>
In-Reply-To: message from Kapeller Rene PSI on Friday June 21
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Friday June 21, rene.kapeller@psi.ch wrote:
> 
> 
> To be precise, the entry in the /etc/exports looks like this:
> /data2  172.19.0.0/255.255.0.0(ro,sync,no_root_squash)
> 
> exportfs -v
> /data2        	172.19.0.0/255.255.0.0(ro,wdelay,no_root_squash)
> 
> cat /proc/fs/nfs/exports
> /data2 
> pc3691.slspn.psi.ch(rw,no_root_squash,sync,wdelay) # 172.19.84.51
> 
> Ooops ...!
> 
> I'm using RedHat-7.3 on the server and on the client (nfs-utils-0.3.3-5)
> 
> Rene
> 

I've just tried that version of nfs-utils and it seems to do the right
thing.

I can either:
    edit /etc/exports, and run "exportfs -r"
or run
    exportfs -io new,option,list hostname:/directory

and it will set the options properly.


Maybe a little explanation of how it all works will help:

/etc/exports contains information about how file systems should
     normally be exported.  This is only read by exportfs.

/var/lib/nfs/etab contains information about what filesystems should
     be exported to whom at the moment.

/var/lib/nfs/rmtab contains a list of which filesystems actually are
     mounted by certain clients at the moment.

/proc/fs/nfs/exports contains information about what filesystems are
     exported to actual client (individual, not subnet or whatever)
     at the moment.

/var/lib/nfs/xtab is the same information as /proc/fs/nfs/exports but
     is maintained by nfs-utils instead of directly by the kernel.  It
     is only used if /proc isn't mounted.

When a mount request arrives, mountd check .../etab to see if that
host is allowed access.  If it is, an entry is placed in .../rmtab and
the filesystem is exported thus creating an entry in
/proc/fs/nfs/exports.


When you run
    exportfs -io  options host:/dir

then the entry in ../etab is changed, or a new one is added.
If it is a subnet/wildcard/netgroup entry, then every line in ../rmtab
is checked to see if it matches.  When a match is found, a
host-specific entry is given to (or changed in) the kernel.

When you run
    exportfs -a

it makes sure that all entries in /etc/exports are properly reflected
in .../etab.  Any extra entries in etab are left alone.  Once the
correct content of etab has been determined, rmtab is examine to
create a list of specific-host entries for any new entries in etab.
This host-specific entries are given to the kernel.

When you run
    exportfs -r
it ignores the prior contents of .../etab and initialises etab to the
contents of /etc/exportfs.  Then it inspects rmtab and make an changes
to /proc/fs/nfs/export that are necessary.


In general, the safest thing to do is edit /etc/exports and run
   exportfs -r

If this leaves you will /proc/fs/nfs/exports containing something that
you didn't expect, please show me the details (exportfs,etab,rmtab)
and I will look again.

NeilBrown


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
