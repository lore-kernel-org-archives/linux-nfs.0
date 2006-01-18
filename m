From: "Edwards, Scott (GE Healthcare)" <J.Scott.Edwards@ge.com>
Subject: RE: Another hang problem - Jukebox error (was: NFS hangs for15 seconds after exportfs -r)
Date: Wed, 18 Jan 2006 15:37:35 -0600
Message-ID: <C664ABFF405D6A458806C03AA2E0FF6B06CBC749@MKEMLVEM01.e2k.ad.ge.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzKzx-0007Q0-F0
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 13:37:45 -0800
Received: from ext-ch1gw-6.online-age.net ([64.37.194.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EzKzv-0001Bw-V9
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 13:37:45 -0800
Received: from int-ch1gw-4.online-age.net (int-ch1gw-4 [3.159.232.68])
	by ext-ch1gw-6.online-age.net (8.13.4/8.13.5/20051111-SVVS-TLS-DNSBL) with ESMTP id k0ILbb66001066
	for <nfs@lists.sourceforge.net>; Wed, 18 Jan 2006 16:37:37 -0500
Received: from cinmlef09.e2k.ad.ge.com (localhost [127.0.0.1])
	by int-ch1gw-4.online-age.net (8.12.9/8.12.3/990426-RLH) with ESMTP id k0ILbaHA029927
	for <nfs@lists.sourceforge.net>; Wed, 18 Jan 2006 16:37:36 -0500 (EST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
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


Hi Trond,

It appears to me that ETIMEDOUT was the only one translated to JUKEBOX
prior to 2.6.9, but this was added in 2.6.9:

msa8002@ox$ diff linux-2.6.9/fs/nfsd/nfsproc.c linux-2.6.8.1/fs/nfsd
589d588
<               { nfserr_jukebox, -EWOULDBLOCK },
msa8002@ox$=20

I don't think we have samba on the machines at all and NFS4 shouldn't
even be active.

I built a 2.6.8.1 kernel this morning and it doesn't exhibit the error.
I am going to build my own 2.6.9 now and see if the custom kernel
somehow affects this problem (the 2.6.6 and 2.6.8.1 kernels have a
custom config and the 2.6.9 kernel is the generic RHEL4/WBEL4 kernel).

Thanks
  -Scott


-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
Sent: Wednesday, January 18, 2006 2:14 PM
To: Edwards, Scott (GE Healthcare)
Cc: Neil Brown; nfs@lists.sourceforge.net
Subject: Re: [NFS] Another hang problem - Jukebox error (was: NFS hangs
for15 seconds after exportfs -r)


On Wed, 2006-01-18 at 11:35 -0600, Edwards, Scott (GE Healthcare) wrote:

> I compared the nfs code from kernel 2.6.6 (our old kernel that
> worked) and 2.6.9 (that causes the error) and discovered that there
> was an addition of a JUKEBOX error from an EWOULDBLOCK in nfsproc.c.
> I couldn't find a difference that would explain why we would be=20
> getting an error when we didn't before (mostly because there were=20
> so many changes I couldn't figure out which one could cause an=20
> error).

AFAICS knfsd will translate ETIMEDOUT into NFS3ERR_JUKEBOX, not
EWOULDBLOCK.

There are two operations in vfs.c that can directly cause this error to
appear:

  setattr if someone else is holding a lease on the file.
  open if someone else is holding a lease on the file.

The only programs I know of that use leases are: knfsd itself (if you
have NFSv4 clients that support delegations) and Samba (in order to
support CIFS oplocks).

Any NFSv4 or Samba activity on this machine?

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
