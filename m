From: Patrick O'Reilly <patrick.oreilly@uni.edu>
Subject: Re: NFS problem
Date: Wed, 21 Aug 2002 14:15:53 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00f801c24947$2b364dc0$66f1a186@OREILLY>
References: <Pine.GHP.4.43.0208212344180.15822-100000@hp10.ccs.iitb.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cougar.uni.edu ([134.161.1.40])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hawx-0001Yo-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 12:15:28 -0700
Received: from OREILLY ([134.161.241.102]) by uni.edu (PMDF V6.1-1 #30560)
 with SMTP id <01KLK9E6CUP88WW9E8@uni.edu> for nfs@lists.sourceforge.net; Wed,
 21 Aug 2002 14:15:23 -0500 (CDT)
To: Suresh Chadive <n8d11007@ccs.iitb.ac.in>, nfs@lists.sourceforge.net
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

>From what I see from the man page of rpcinfo, try a

rpcinfo -s <server>

from the client and see what services are there and what program number they
are associated with.  Sure enough my portmap service is program 100000, just
as yours complains about not finding.  If the services are showing up when
you issue rpcinfo -p from the server, they should be there and show program
number from the above command.  If you generically say:

rpcinfo -u <server> portmap

it may automatically look for program number 100000 and all I can think of
is that your portmap service is not running under that program number.  Not
sure why it wouldn't be.  If it isn't then substitute the program number for
portmap in the above command and see what you find.

Patrick

----- Original Message -----
From: "Suresh Chadive" <n8d11007@ccs.iitb.ac.in>
To: <nfs@lists.sourceforge.net>
Sent: Wednesday, August 21, 2002 1:45 PM
Subject: Re: [NFS] NFS problem


>
> Thank you very much for the support I got. It is
> really timely help to me.
>
> The suggestions helped me in making a breakthrough,
> however, still the problem persists. I think I have
> rounded off the critical thing now.
>
> 1) The portmap, nfs, nfslock were off for the levels 345
>    I rectified it. Now the client also shows all the important
>    daemons running.
>
> 2) - rpcinfo -p on server and client now give all the daemons.
>     ----------------------------------------------------------
>    - also, the command:
>
> $ rpcinfo -p server
>      produces the same input as obtained on the server (issuing
>      ----------------------------------------------  rpcinfo -p)
>
>     Interesting part is
>
> $ rpcinfo -u server nfs
>         $ rpcinfo -u server portmap
>
>     are getting timed out !!!!. They produce (for the case of portmap):
>
>                 rpcinfo: RPC: Port mapper failure - RPC: Timed out
> program 100000 is not available
>
>
>     Will this give any clue to the problem?
>
>
>  3) The mounting on to the server itself is successful !
>     Is it that server side is absolutely OK?
>
>
> Eagerly looking for the final shot...
>
>
> Best regards,
> -suresh
>
>
> ----------------------
> SURESH CHADIVE
>
> V Yr,
> Dual degree Programme
>
> H9, #319,
> IIT Bombay
>
> e-mail :  csuresh@iitbombay.org
>
>
>
>
>
> -------------------------------------------------------
> This sf.net email is sponsored by: OSDN - Tired of that same old
> cell phone?  Get a new here for FREE!
> https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
