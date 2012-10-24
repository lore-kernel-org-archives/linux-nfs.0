Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29748 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757995Ab2JXUbR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 16:31:17 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: RE: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
Date: Wed, 24 Oct 2012 20:31:16 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA909290827@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121016125832.GC30649@fieldses.org>
 <20121024200249.GC6697@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092906F7@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024201517.GD6697@fieldses.org>
In-Reply-To: <20121024201517.GD6697@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Wednesday, October 24, 2012 4:15 PM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org; Schumaker, Bryan
> Subject: Re: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
> 
> On Wed, Oct 24, 2012 at 08:07:55PM +0000, Myklebust, Trond wrote:
> > > -----Original Message-----
> > > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > > owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> > > Sent: Wednesday, October 24, 2012 4:03 PM
> > > To: linux-nfs@vger.kernel.org; Myklebust, Trond; Schumaker, Bryan
> > > Subject: Re: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
> > >
> > > Anyone get a chance to look at this?  It seems very reproduceable.
> > >
> > > --b.
> > >
> > > On Tue, Oct 16, 2012 at 08:58:32AM -0400, bfields wrote:
> > > > On 3.7-rc1:
> > > >
> > > > 	client# mount -tnfs -osec=krb5,vers=3 server:/exports/ext4 /mnt/
> > > >
> > > > 		server# ls -l /exports/ext4|grep TMP
> > > > 		server#
> > > >
> > > > 	# mkdir /mnt/TMP
> > > > 	mkdir: cannot create directory `/mnt/TMP': Permission denied
> > > >
> > > > 		server# ls -l /exports/ext4|grep TMP
> > > > 		drwxr-xr-x  2 nfsnobody nfsnobody 4096 Oct 16 08:56 TMP
> > > > 		server#
> > > >
> > > > Wireshark also shows that the create succeeds.
> >
> > Can you share the wireshark trace?
> 
> Sure.  This covers the mount and mkdir.  The mkdir call and reply are in
> frames 77 and 78.

Hmm.... Can you please check if the ACL is being set correctly on the server? I suspect that might be the source of the error.

Cheers
  Trond
