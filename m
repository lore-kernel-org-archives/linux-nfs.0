Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:44382 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755372AbaIHXLz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 19:11:55 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 8 Sep 2014 17:11:55 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 5E9EA19D8039
	for <linux-nfs@vger.kernel.org>; Mon,  8 Sep 2014 17:11:39 -0600 (MDT)
Received: from b03eismtpcl100.ahe.boulder.ibm.com (b03eismtpcl100.ahe.boulder.ibm.com [9.17.195.167])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s88NBqYA29163528
	for <linux-nfs@vger.kernel.org>; Tue, 9 Sep 2014 01:11:52 +0200
Received: from b03eismtpcl100.ahe.boulder.ibm.com (localhost [127.0.0.1])
	by b03eismtpcl100.ahe.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s88NBphN003450
	for <linux-nfs@vger.kernel.org>; Mon, 8 Sep 2014 17:11:52 -0600
Date: Mon, 8 Sep 2014 18:11:51 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Andrew Martin <amartin@xes-inc.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Clarification on client "async" option
Message-ID: <20140908231150.GA11508@us.ibm.com>
References: <2124227602.386654.1409868802614.JavaMail.zimbra@xes-inc.com>
 <584874869.387720.1409869399398.JavaMail.zimbra@xes-inc.com>
 <CAHQdGtT3iwdTXB3ecKSbao=yErOzv8NREPta1A5mOtwYxmRb8Q@mail.gmail.com>
 <2037985632.307306.1410202186698.JavaMail.zimbra@xes-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2037985632.307306.1410202186698.JavaMail.zimbra@xes-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andrew Martin [amartin@xes-inc.com] wrote:
> ----- Original Message -----
> > From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> > > This shows that a temporary filename is written and then closed, however
> > > the
> > > file is then chmodded and renamed to the final destination filename. Do the
> > > chmod(2) and rename(2) calls force a COMMIT to be sent, flushing these
> > > changes
> > > to stable storage on the NFS server? Or, is there a possibility that during
> > > a
> > > power failure of both client and server, the file would remain as
> > > .dest.y4ihWF
> > > on the server?
> > 
> > In NFSv3, the close() will cause the client to flush all data to stable
> > storage.
> > The client will also flush data to stable storage on a chmod, since
> > that could potentially affect its ability to write back the data. It
> > will not bother to do so for rename.
> > An application should normally be able to rely on the data being
> > safely on disk in both these situations provided that the server
> > honours the NFS protocol (with a caveat that an ill-timed 'kill -9'
> > could interrupt the process of flushing).
> > 
> > All metadata operations such as create, chmod, rename, etc. will cause
> > the server to flush the file metadata to disk assuming that you set
> > the (highly recommended) "sync" export option. If "sync" is set, the
> > server will also honour COMMIT requests by flushing the data to stable
> > storage.
> 
> Thanks for the clarification - I will use "sync" on the server side and
> "async" on the client side, since I know now that this combination will
> provide both data and metadata safety.

That should be the default too.

