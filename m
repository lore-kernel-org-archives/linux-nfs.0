From: Suresh Chadive <n8d11007@ccs.iitb.ac.in>
Subject: Re: NFS problem
Date: Thu, 22 Aug 2002 00:15:55 +0530 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GHP.4.43.0208212344180.15822-100000@hp10.ccs.iitb.ernet.in>
References: <Pine.LNX.4.44.0208202241440.3445-100000@linux2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailhost.iitb.ac.in ([203.197.74.142])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17haRD-00024Q-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 11:42:39 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0208202241440.3445-100000@linux2>
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


Thank you very much for the support I got. It is
really timely help to me.

The suggestions helped me in making a breakthrough,
however, still the problem persists. I think I have
rounded off the critical thing now.

1) The portmap, nfs, nfslock were off for the levels 345
   I rectified it. Now the client also shows all the important
   daemons running.

2) - rpcinfo -p on server and client now give all the daemons.
    ----------------------------------------------------------
   - also, the command:

	$ rpcinfo -p server
     produces the same input as obtained on the server (issuing
     ----------------------------------------------  rpcinfo -p)

    Interesting part is

	$ rpcinfo -u server nfs
        $ rpcinfo -u server portmap

    are getting timed out !!!!. They produce (for the case of portmap):

                rpcinfo: RPC: Port mapper failure - RPC: Timed out
		program 100000 is not available


    Will this give any clue to the problem?


 3) The mounting on to the server itself is successful !
    Is it that server side is absolutely OK?


Eagerly looking for the final shot...


Best regards,
-suresh


----------------------
SURESH CHADIVE

V Yr,
Dual degree Programme

H9, #319,
IIT Bombay

e-mail :  csuresh@iitbombay.org





-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
