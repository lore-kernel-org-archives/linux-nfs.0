From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: query about clnt_create
Date: Tue, 21 Feb 2006 05:15:40 -0800 (PST)
Message-ID: <20060221131540.24078.qmail@web51602.mail.yahoo.com>
References: <1140527500.7864.42.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBXMq-0001Y6-T1
	for nfs@lists.sourceforge.net; Tue, 21 Feb 2006 05:15:48 -0800
Received: from web51602.mail.yahoo.com ([206.190.38.207])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FBXMp-00021e-8v
	for nfs@lists.sourceforge.net; Tue, 21 Feb 2006 05:15:48 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1140527500.7864.42.camel@lade.trondhjem.org>
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

Hi Trond,
  perhaps i was not clear.
  I am talking about timeout for clnt_create
  and not about clnt_call which already has
  client handle in place. clnt_control will act on=20
  client handle and i am searching for something which

  will create client handle within specified timeout=20
  if possible.


thanks,
 kiran

--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:

> On Tue, 2006-02-21 at 00:39 -0800, mehta kiran
> wrote:
> > I noticed that clnt_create takes 3.5 min for tcp
> > and 1 min for udp protocol by default
> > (when taget system in UNREACHABLE). Anyway to
> modify
> > default timeout ? I could see that there are
> > functions like clnt_create_timed on  solaris
> 5.8/5.9
> > but not on linux.
>=20
> 'man 3 rpc' and look for the clnt_control() function
>=20
> Cheers
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
