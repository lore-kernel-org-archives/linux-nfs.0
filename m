From: Shivaji Navale <shivaji@ee.iitb.ac.in>
Subject: Mailbox corruption on The NFS server
Date: Tue, 2 Dec 2003 16:56:38 +0530 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.44.0312021646390.9111-100000@bhairav.ee.iitb.ac.in>
References: <Pine.LNX.4.44.0312011235290.23297-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AR8g2-0002hX-6n
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 03:26:46 -0800
Received: from [203.199.51.149] (helo=smtp1.iitb.ac.in)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AR8g1-0004rK-BK
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 03:26:45 -0800
Received: from localhost (shivaji@localhost)
	by ee.iitb.ac.in (8.12.4/8.12.4/Submit) with ESMTP id hB2BQciu010824
	for <nfs@lists.sourceforge.net>; Tue, 2 Dec 2003 16:56:39 +0530 (IST)
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.44.0312011235290.23297-100000@kenzo.iwr.uni-heidelberg.de>
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

Hi,

We have this peculiar problem for the Mailboxes of users
/var/spool/mail/username.
The mailboxes get corrupted asto the first 20-26 lines of mailbox get
DELETED.

We are using 2.4.20-18.8.um.1 kernel on the (LVS Director) which exports
the mail partition to 30 NFS/NIS clients.

i am not sure if this would be the right place
to ask this question, but this is a problem bugging us since long.

Googled extensively, but couldnt work out the proper solution.

Could anybody suggest, why this is happening and how it could be overcome.
Thanks a lot

portmapper gives following results

    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100004    2   udp    953  ypserv
    100004    1   udp    953  ypserv
    100004    2   tcp    956  ypserv
    100004    1   tcp    956  ypserv
    391002    2   tcp  32769  sgi_fam
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100005    1   udp  32771  mountd
    100005    1   tcp  32770  mountd
    100005    2   udp  32771  mountd
    100005    2   tcp  32770  mountd
    100005    3   udp  32771  mountd
    100005    3   tcp  32770  mountd
    100009    1   udp    668  yppasswdd
    100011    1   udp    907  rquotad
    100011    2   udp    907  rquotad
    100011    1   tcp    910  rquotad
    100011    2   tcp    910  rquotad


i am not sure if this would be the right place
to ask this question, but this is a problem bugging us since long.

Googled extensively, but couldnt work out the proper solution.


-- EVERYONE should contribute to THE BEST of their capacity
for THE DEVELOPMENT of THE NATION
					 -- A P J KALAM

On Mon, 1 Dec 2003, Bogdan Costescu wrote:

> On Mon, 1 Dec 2003, Greg Banks wrote:
>
> > It's not that simple; the ia64 port can be configured for 64K pages,
> > which would result in nfsd reporting 128K for wtmax on UDP.
>
> But allocating only 32K in this case means half a page... A waste. Then
> maybe TCP should get its own setting ?
>
> --
> Bogdan Costescu
>
> IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
> Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
> Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
> E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
>
>
>
> -------------------------------------------------------
> This SF.net email is sponsored by: SF.net Giveback Program.
> Does SourceForge.net help you be more productive?  Does it
> help you create better code?  SHARE THE LOVE, and help us help
> YOU!  Click Here: http://sourceforge.net/donate/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
