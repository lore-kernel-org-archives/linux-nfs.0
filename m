Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40439 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932139Ab1GNRZH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2011 13:25:07 -0400
Date: Thu, 14 Jul 2011 13:25:05 -0400
To: "Assarsson, Emil" <Emil.Assarsson@sonyericsson.com>
Cc: "'Richard Smits'" <R.Smits@tudelft.nl>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: krb5 mount with large group membership
Message-ID: <20110714172504.GA19003@fieldses.org>
References: <4E1EB72E.5080803@tudelft.nl>
 <2BF070A7A2375D46BA1B6087F8D5DCB67E846BA792@seldmbx01.corpusers.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2BF070A7A2375D46BA1B6087F8D5DCB67E846BA792@seldmbx01.corpusers.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 14, 2011 at 01:14:07PM +0200, Assarsson, Emil wrote:
> Hi,
> 
> Your ticket is probably oversized for the NFS server.
> Try set NO_AUTH_DATA_REQUIRED (google msn) on the object holding the servers SPN.

The server has trouble with init_sec_context tokens that are longer than
a few k--I'd have to check the exact limit.  (I wonder how big this one
is?)

--b.

> 
> --
> Emil Assarsson
> 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
> > On Behalf Of Richard Smits
> > Sent: torsdag den 14 juli 2011 11:30
> > To: linux-nfs@vger.kernel.org
> > Subject: krb5 mount with large group membership
> > 
> > Hello list,
> > 
> > I am running into a problem. Perhaps someone understands what is
> > happening here. I will explain.
> > 
> > I have a Redhat 5.4 client that is accessing a nfs export on a NFS
> > server. (Redhat 6.1)
> > 
> > Our KDC is a Windows AD.
> > 
> > The client is using samba-winbind. If a user is a member of 23 groups or
> > lower, I can access the export. If a user is a member of more groups,
> > the mount fails with a "Permission denied"
> > 
> > mount /data
> > -bash-3.2$ cd /data
> > -bash: cd: /data: Permission denied
> > 
> > Thew odd thing is if I try a mount to our Netapp filer with also a krb5
> > export, there is no problem.
> > 
> > This has to do something with the ticket size in combination with
> > memberships to a large number of groups.
> > 
> > So what must i do to get this Redhat server working with this setup ? It
> > seems that Netapp did something to get this working ?
> > 
> > Does this sound familiar to anyone, or should i provide more information ?
> > 
> > Versions server side :
> > nfs-utils-1.2.3-7
> > krb5-workstation-1.9-9
> > 
> > Greetings ... Richard Smits
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
