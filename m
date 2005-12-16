From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: NFS Client  port
Date: Thu, 15 Dec 2005 18:31:47 -0800 (PST)
Message-ID: <20051216023147.51739.qmail@web51602.mail.yahoo.com>
References: <43A19A27.2040209@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1En5Nz-0005LO-72
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 18:31:55 -0800
Received: from web51602.mail.yahoo.com ([206.190.38.207])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1En5Nx-0006kq-NQ
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 18:31:55 -0800
To: cel@citi.umich.edu
In-Reply-To: <43A19A27.2040209@citi.umich.edu>
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

Hi,
    Any specific reason to make NFS Client connect on=20
    the same port or is it to make it simialr
to/follow=20
    Solaris implementation where NFS Client connects
with
    same port?

thanks,
 kiran


--- Chuck Lever <cel@citi.umich.edu> wrote:

> mehta kiran wrote:
> > Hi,
> >    Does NFS Client try to use port different then
> the
> > port
> >    most recently released or next in the series ?
> >=20
> >    NFS client is using some port say x
> >    Due to some reason connection between client=20
> >    and server is broken. Will NFS Client
> >    use the port x to reestablish connection or
> will it
> >=20
> >    use port other then x ?
>=20
> until very recently, the RPC client would choose a
> different port when=20
> reconnecting.  there's a patch in the transport
> switch series that i=20
> believe is going in 2.6.15 that makes the client
> reconnect on the same port.
> > begin:vcard
> fn:Chuck Lever
> n:Lever;Charles
> org:Network Appliance, Incorporated;Open Source NFS
> Client Development
> adr:535 West William Street, Suite 3100;;Center for
> Information Technology Integration;Ann
> Arbor;MI;48103-4943;USA
> email;internet:cel@citi.umich.edu
> title:Member of Technical Staff
> tel;work:+1 734 763-4415
> tel;fax:+1 734 763 4434
> tel;home:+1 734 668-1089
> x-mozilla-html:FALSE
> url:http://troy.citi.umich.edu/u/cel/
> version:2.1
> end:vcard
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
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
