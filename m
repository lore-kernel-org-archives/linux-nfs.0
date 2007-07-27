From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Status of mount.nfs
Date: Fri, 27 Jul 2007 13:13:26 -0400
Message-ID: <1185556406.6586.45.camel@localhost>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>
	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>
	<46A7A5F8.4040204@oracle.com> <46A897CD.50201@RedHat.com>
	<46A96032.7080503@oracle.com>  <46AA089E.50503@RedHat.com>
	<1185551769.6586.28.camel@localhost>  <46AA1A70.5010705@RedHat.com>
	<1185553679.6586.34.camel@localhost>  <46AA2642.60505@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IETNa-0004Ps-Hq
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 10:13:30 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/Jx9JcZxPOzT9XyNRF6sVqls8uzfXp4rw=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IETNc-0001dM-Ui
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 10:13:34 -0700
In-Reply-To: <46AA2642.60505@RedHat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-07-27 at 13:07 -0400, Steve Dickson wrote:

> After how long of a wait? If all the timeouts are controllable then
> I agrees, but if we have to wait undefined-able amount of time for
> every RPC retransmit, then I think we should do a ping...

You should be able to set the timeout either on a per-RPC call basis by
using clnt_call(), or by changing the default timeout on the CLIENT
object using clnt_control() (man 3 rpc).

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
