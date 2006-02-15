From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: query about clnt_create
Date: Wed, 15 Feb 2006 08:16:42 -0800 (PST)
Message-ID: <20060215161642.58912.qmail@web51607.mail.yahoo.com>
References: <4d569c330602150808m2a2abe9dxc041eb16b5d926c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9PKj-0004MF-Ek
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 08:16:49 -0800
Received: from web51607.mail.yahoo.com ([206.190.38.212])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1F9PKi-0002fY-Rt
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 08:16:49 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <4d569c330602150808m2a2abe9dxc041eb16b5d926c3@mail.gmail.com>
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


Hi Kevin,
      Sorry for not mentioning this.
      I do not get any error.
      Customers can have different settings
      for NFS daemons.
      I just want to confirm if
      clnt_create is a realiable=20
      way  to monitor different=20
      versions of nfsd  running.
     =20
thanks,
 kiran
     =20

     =20
     =20
=20

--- Kevin Coffman <kwc@citi.umich.edu> wrote:

> What kind of error do you get back from the
> clnt_create() ?
>=20
> On 2/15/06, mehta kiran <kiranmehta1981@yahoo.com>
> wrote:
> > Hi,
> >     Can clnt_create for NFS versions fail in any
> >     case due to security setting on NFS Sever ?
> >     Description: NFS client can mount exported FS.
> >     I have a small application which detects
> >     health of NFS server by creating client
> >     handle for required NFS version+protocol.
> >     Can this ever fail consistenly
> >     due to security or any other
> >     settings on NFS server
> >     (nfs client system and server are connected to
> >     network, there is no hardware/(network load)
> >     problem and portmapper + all nfs daemons are
> >     runnnig)?
> >
> > thanks,
> >  kiran
> >
> >
> > __________________________________________________
> > Do You Yahoo!?
> > Tired of spam?  Yahoo! Mail has the best spam
> protection around
> > http://mail.yahoo.com
> >
> >
> >
>
-------------------------------------------------------
> > This SF.net email is sponsored by: Splunk Inc. Do
> you grep through log files
> > for problems?  Stop!  Download the new AJAX search
> engine that makes
> > searching your log files as easy as surfing the=20
> web.  DOWNLOAD SPLUNK!
> >
>
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D103432&bid=3D230486&dat=3D=
121642
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
>=20

--- Kevin Coffman <kwc@citi.umich.edu> wrote:

> What kind of error do you get back from the
> clnt_create() ?
>=20
> On 2/15/06, mehta kiran <kiranmehta1981@yahoo.com>
> wrote:
> > Hi,
> >     Can clnt_create for NFS versions fail in any
> >     case due to security setting on NFS Sever ?
> >     Description: NFS client can mount exported FS.
> >     I have a small application which detects
> >     health of NFS server by creating client
> >     handle for required NFS version+protocol.
> >     Can this ever fail consistenly
> >     due to security or any other
> >     settings on NFS server
> >     (nfs client system and server are connected to
> >     network, there is no hardware/(network load)
> >     problem and portmapper + all nfs daemons are
> >     runnnig)?
> >
> > thanks,
> >  kiran
> >
> >
> > __________________________________________________
> > Do You Yahoo!?
> > Tired of spam?  Yahoo! Mail has the best spam
> protection around
> > http://mail.yahoo.com
> >
> >
> >
>
-------------------------------------------------------
> > This SF.net email is sponsored by: Splunk Inc. Do
> you grep through log files
> > for problems?  Stop!  Download the new AJAX search
> engine that makes
> > searching your log files as easy as surfing the=20
> web.  DOWNLOAD SPLUNK!
> >
>
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D103432&bid=3D230486&dat=3D=
121642
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
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
