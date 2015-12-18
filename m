Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e18.ny.us.ibm.com ([129.33.205.208]:43623 "EHLO
	e18.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259AbbLRAha convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Dec 2015 19:37:30 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 17 Dec 2015 19:37:29 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id D5D486E803F
	for <linux-nfs@vger.kernel.org>; Thu, 17 Dec 2015 19:25:36 -0500 (EST)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tBI0bRfw31653980
	for <linux-nfs@vger.kernel.org>; Fri, 18 Dec 2015 00:37:27 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tBI0YF87001078
	for <linux-nfs@vger.kernel.org>; Thu, 17 Dec 2015 19:34:16 -0500
Date: Thu, 17 Dec 2015 18:37:22 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Soumya Koduri <skoduri@redhat.com>
Cc: Omar Walid Llorente <omar@dit.upm.es>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        =?iso-8859-1?Q?administraci=F3n_del_centro_de_c=E1lculo?= del
	 dit <cdc@dit.upm.es>
Subject: Re: possible bug in nfs-kernel-server
Message-ID: <20151218003722.GA1452@us.ibm.com>
References: <564EFE51.90105@dit.upm.es>
 <20151121091824.71ab1f6b@tlielax.poochiereds.net>
 <b259acd35a93bd2293630c35b8761e6b@dit.upm.es>
 <566954D6.7090508@dit.upm.es>
 <5669702D.50402@redhat.com>
 <20151210144434.GB12544@fieldses.org>
 <566EF4E4.60809@dit.upm.es>
 <5672A78D.4090303@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <5672A78D.4090303@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

IIRC, permission checks are done in open(). write/read syscalls should
NOT do much access checks (at least based on POSIX). This is why once an
open is done, you remove permissions for that process, but it should
still be able to read/write based on the open flags it did when it
opened the file.

I don't know all the details of this defect, but gluster seems to be
doing what it is supposed to do.

Regards, Malahal.

Soumya Koduri [skoduri@redhat.com] wrote:
> As mentioned by Bruce, GlusterFS doesn't have owner-override rule
> except for setattr.
> 
> I did few experiments to check why this test case passes on plain
> glusterfs fuse mount & NFS-Ganesha but fails with kernel-NFS.
> 
> NFS-Ganesha (for most of the FSALs) seem to be passing the actual
> request credentials to the back-end filesystem only for
> CREATE(-like) and UNLINK fops. For all the remaining fops, it does
> the access check at its end and then perform the operation with root
> credentials. That's the reason WRITE succeeded in your case as
> NFS-Ganesha (like kernel-NFS) skipped the access check if the
> request caller_uid proved to be the file's owner.
> 
> In case of native GlusterFS FUSE mount, there is no OPEN fop
> involved. WRITE is performed on the fd returned by CREATE. And
> strangely GlusterFS seem to be doing certain access checks only
> during OPEN but not for WRITE (this seems like a bug and probably
> needs to be fixed in Gluster).
> 
> Thanks,
> Soumya
> 
> On 12/14/2015 10:27 PM, Omar Walid Llorente wrote:
> >
> >Thank you Bruce, others, for the responses. I send attached a complete
> >capture of the issue, including the glusterfs transactions.
> >
> >Hope this helps to clear where may it be...
> >
> >Omar
> >
> >El 10/12/15 a las 15:44, J. Bruce Fields escribió:
> >>On Thu, Dec 10, 2015 at 05:59:33PM +0530, Soumya Koduri wrote:
> >>>
> >>>On 12/10/2015 04:02 PM, Omar Walid Llorente wrote:
> >>>>Hi, Jeff, Bruce, finally I got some time to get the capture of the nfs
> >>>>packets (you can find them in attached file nfs-problem-nks.pcap.zip).
> >>>>Sorry for being so late.
> >>>>
> >>>>What I did was the following:
> >>>>
> >>>>1st) Create the RO file:
> >>>>cdc@l056:~/prueba-git$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt;
> >>>>chmod 444 444.txt;
> >>>>
> >>>>2nd) Init the capture:
> >>>>root@l056:~# tcpdump -i eth2 -w /tmp/nfs.pcap -s 512 port 2049
> >>>>tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size
> >>>>512 bytes
> >>>>
> >>>GlusterFS protocol is added to wireshark from version 1.8.0 [1]. It
> >>>may be helpful to see what GlusterFS operations are being processed
> >>>as part of NFS WRITE call (which has failed in this case).
> >>>
> >>>Could you please try taking the packet trace on the machine where
> >>>NFS server is running (without filtering out based on the port
> >>>number).
> >>>
> >>>Also I tried out the same test on Fedora22 machine, but haven't run
> >>>into any issue. What are the fuse mount options you have used to
> >>>mount gluster volume?
> >>Oh, I think this is a simple problem (but maybe hard to fix).  The
> >>capture shows NFSv3 traffic like:
> >>
> >>    CREATE -> OK
> >>    SETATTR (mode set to 0400) -> OK
> >>    WRITE -> NFS3ERR_ACCES
> >>
> >>That write would succeed locally (because the mode doesn't matter to a
> >>local application that already holds the file open).  It would fail over
> >>NFSv3, which doesn't know about the open--except that there's a hack for
> >>this case: NFSv3 servers allow IO operations to ignore the mode, if the
> >>operation comes from the owner of the file.  NFSv3 clients are then
> >>careful to perform necessary access checks on open to ensure that this
> >>owner-override rule doesn't grant too many permissions.
> >>
> >>That allows NFSv3 applications to see behavior that's mostly like a
> >>local filesystem, without opening much of a security hole (since the
> >>owner could always chmod anyway).
> >>
> >>So, knfsd is making this special exception--but gluster (which I believe
> >>it's exporting in this case, via fuse?)--probably doesn't....  I'm not
> >>sure what you can do about that.
> >>
> >>--b.
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

