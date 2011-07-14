Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:19615 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754955Ab1GNN3w convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2011 09:29:52 -0400
From: "Assarsson, Emil" <Emil.Assarsson@sonyericsson.com>
To: "'Richard Smits'" <R.Smits@tudelft.nl>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 14 Jul 2011 15:29:49 +0200
Subject: RE: krb5 mount with large group membership
Message-ID: <2BF070A7A2375D46BA1B6087F8D5DCB67E846BA793@seldmbx01.corpusers.net>
References: <4E1EB72E.5080803@tudelft.nl>
 <2BF070A7A2375D46BA1B6087F8D5DCB67E846BA792@seldmbx01.corpusers.net>
 <4E1EE908.5030204@tudelft.nl>
In-Reply-To: <4E1EE908.5030204@tudelft.nl>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

Pre-authentication errors:

Try to limit the /etc/krb5.conf to use the 3 closest KDC's only.
I'm using winbind and link /etc/krb5.conf to /var/run/samba/smb_krb5/krb5.conf.* (there should be a "locate" module for mit-krb5 but lucid doesn't provide it).

It can be solved with do not require but I think it's better to solve the real problem.
--
Emil Assarsson

> -----Original Message-----
> From: Richard Smits [mailto:R.Smits@tudelft.nl]
> Sent: torsdag den 14 juli 2011 15:03
> To: linux-nfs@vger.kernel.org
> Cc: Assarsson, Emil
> Subject: Re: krb5 mount with large group membership
> 
> Hi,
> 
> Good tip. Thank you.
> 
> note : If I check the "Do not require Kerberos preauthentication" in the
> AD on my testaccount, it works...
> 
> So now i have to look what else this breaks.
> 
> Greetings .. Richard
> 
> On 07/14/2011 01:14 PM, Assarsson, Emil wrote:
> > Hi,
> >
> > Your ticket is probably oversized for the NFS server.
> > Try set NO_AUTH_DATA_REQUIRED (google msn) on the object holding the servers
> SPN.
> >
> > --
> > Emil Assarsson
> >
> >> -----Original Message-----
> >> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org]
> >> On Behalf Of Richard Smits
> >> Sent: torsdag den 14 juli 2011 11:30
> >> To: linux-nfs@vger.kernel.org
> >> Subject: krb5 mount with large group membership
> >>
> >> Hello list,
> >>
> >> I am running into a problem. Perhaps someone understands what is
> >> happening here. I will explain.
> >>
> >> I have a Redhat 5.4 client that is accessing a nfs export on a NFS
> >> server. (Redhat 6.1)
> >>
> >> Our KDC is a Windows AD.
> >>
> >> The client is using samba-winbind. If a user is a member of 23 groups or
> >> lower, I can access the export. If a user is a member of more groups,
> >> the mount fails with a "Permission denied"
> >>
> >> mount /data
> >> -bash-3.2$ cd /data
> >> -bash: cd: /data: Permission denied
> >>
> >> Thew odd thing is if I try a mount to our Netapp filer with also a krb5
> >> export, there is no problem.
> >>
> >> This has to do something with the ticket size in combination with
> >> memberships to a large number of groups.
> >>
> >> So what must i do to get this Redhat server working with this setup ? It
> >> seems that Netapp did something to get this working ?
> >>
> >> Does this sound familiar to anyone, or should i provide more information ?
> >>
> >> Versions server side :
> >> nfs-utils-1.2.3-7
> >> krb5-workstation-1.9-9
> >>
> >> Greetings ... Richard Smits
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
