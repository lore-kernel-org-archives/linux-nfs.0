From: me@networks-and-security.de
Subject: Re: AW: NFS & Clustering
Date: Wed, 4 Sep 2002 11:55:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF16CD4D07.2F1B363A-ONC1256C2A.00364F10-C1256C2A.0035A2BB@networks-and-security.de>
References: <95AF67BA7F70D511829B0002A551737001C9CC@faw-e01.faw.freudenberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Marco.Schwarz@Freudenberg.de,
	NFS@lists.sourceforge.net,
	nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <95AF67BA7F70D511829B0002A551737001C9CC@faw-e01.faw.freudenberg.de>
To: Marco.Schwarz@Freudenberg.de
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





Hallo Marco,

have you tried nfs with heartbeat and drbd?
At this time we are evaluating this scenario because we will use it in =
our
production environment. At this time there is a limitation, drdb works =
only
with two servers.

Bye
Markus





                                                                       =
    
             Marco.                                                    =
    
             Schwarz@Freudenb                                          =
    
             erg.de                                                    =
 To 
             Sent by: nfs-            Marco.Schwarz@Freudenberg.de     =
    
             admin@lists.                                              =
 cc 
             sourceforge.net          NFS@lists.sourceforge.net        =
    
                                                                   Subj=
ect 
                                      AW: [NFS] NFS & Clustering       =
    
             04.09.2002 11:26                                          =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




Small appendix:

What we are looking for is basically a high-availability solution for o=
ur
NFS server(s). With the numbers of our diskless clients growing, we sim=
ply
cannot afford downtimes (this is an industrial production environment).=


My options are to either find a high-availabilty solution for the NFS
server
or to make the clients work when the server is down. I think I'll try t=
he
clustering/HA first ;-)

Regards,
Marco

> -----Urspr=FCngliche Nachricht-----
> Von:             Marco.Schwarz@Freudenberg.de [SMTP:Marco.
Schwarz@Freudenberg.de]
> Gesendet am:           Mittwoch, 4. September 2002 10:35
> An:        NFS@lists.sourceforge.net
> Betreff:         [NFS] NFS & Clustering
>
> Hi all,
>
> we are looking into the possibility of building a clustered NFS-root
> server
> for our diskless clients. Does anybody know if this is possible with =
NFS
> and
> which cluster software is best for this task (OpenMOSIX ?).
>
> Thanks in advance,
> Marco
>
>
> -------------------------------------------------------
> This sf.net email is sponsored by: OSDN - Tired of that same old
> cell phone?  Get a new here for FREE!
> https://www.inphonic.com/r.asp?r=3Dsourceforge1&refcode1=3Dvs3390
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=3Dsourceforge1&refcode1=3Dvs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
=




-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
