From: "Jacky Lam" <faichai0@yahoo.com>
Subject: Re: Application locked when network crash
Date: Tue, 17 Jun 2003 23:38:33 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00a801c334e6$82d7d090$0202a8c0@jackyhome>
References: <31B1521BD986E84E9D43651F8DF99BDC0134B40B@POEXMB1.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from imsmq04.netvigator.com ([218.102.48.40])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SIXN-0003NF-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 08:38:21 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>,
	<nfs@lists.sourceforge.net>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



    Then, can I use remount to change to option hard/soft according to my
needs in realtime?
    Thanks.

Jacky

----- Original Message -----
From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
To: "Jacky Lam" <faichai0@yahoo.com>; <nfs@lists.sourceforge.net>
Sent: Tuesday, June 17, 2003 11:26 PM
Subject: RE: [NFS] Application locked when network crash


>
> Put intr on the nfs mount and then you can usually ctrl-c the
> application, it generally will take a few seconds for the application
> to respond to the ctrl-c, the other option is to use soft mounts,
> but if your network is less than perfect or your server is overloaded
> this will often cause lots of timeouts that will cause the application
> to crash when there is no problem except the network being slow.
> See "man nfs" and the nfs section of "man mount".
>
> Generally this hanging is the desired behavior when the network
> is expected to come back as this causes the least damage to
> the users running on the machine as the job in question will
> continue where it left off if the server has sync on the exports
> of the given filesystem (see "man exports").
>
>                               Roger
>
> > -----Original Message-----
> > From: Jacky Lam [SMTP:faichai0@yahoo.com]
> > Sent: Tuesday, June 17, 2003 9:49 AM
> > To: nfs@lists.sourceforge.net
> > Subject: [NFS] Application locked when network crash
> >
> > Dear all,
> >
> >     I am not very familiar with nfs. Currently, I connect a client with
an
> > nfs server. When the client is reading/writing from/to the server, the
> > network is crashed(I repeat the problem by removing the network cable).
> > Then, the client is hanged. How can the client get out from the hang in
> > customed timeout(or at least in short period of time)? Thanks very much.
> >
> >     (Please cc to my email because I haven't subscribed the list yet.
> > Thanks)
> >
> > Yours,
> > Jacky
> >
> >
> >
> > -------------------------------------------------------
> > This SF.Net email is sponsored by: INetU
> > Attention Web Developers & Consultants: Become An INetU Hosting Partner.
> > Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
> > INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
