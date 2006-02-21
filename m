From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: query about clnt_create
Date: Tue, 21 Feb 2006 00:39:48 -0800 (PST)
Message-ID: <20060221083948.5152.qmail@web51601.mail.yahoo.com>
References: <1140104058.8891.36.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBT3s-0007kR-0T
	for nfs@lists.sourceforge.net; Tue, 21 Feb 2006 00:39:56 -0800
Received: from web51601.mail.yahoo.com ([206.190.38.206])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FBT3q-0001Vv-KT
	for nfs@lists.sourceforge.net; Tue, 21 Feb 2006 00:39:56 -0800
To: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
In-Reply-To: <1140104058.8891.36.camel@lade.trondhjem.org>
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

I noticed that clnt_create takes 3.5 min for tcp
and 1 min for udp protocol by default
(when taget system in UNREACHABLE). Anyway to modify
default timeout ? I could see that there are
functions like clnt_create_timed on  solaris 5.8/5.9
but not on linux.

thanks,
 kiran

--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:

> On Thu, 2006-02-16 at 03:58 -0800, mehta kiran
> wrote:
> > Hi Trond,
> >=20
> > May be i am confused.
> > But, is this  assumption ok :
> > that clnt_create/clnt_call call  from a client
> system
> > will not fail due to any kind of security
> > settings(kerberos,firewall) on the nfs server
> > ( PS: client system can mount exported fs from
> > nfs server) ?
>=20
> Of course clnt_call can fail due to security
> settings on the server:
> they wouldn't be much use for security purposes if
> they didn't stop an
> actual RPC call. :-)
>=20
> clnt_create might succeed, though, since it doesn't
> actually try to talk
> to the server.
>=20
> Cheers,
>   Trond
>=20
>=20


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D103432&bid=3D230486&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
