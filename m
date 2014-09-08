Return-Path: linux-nfs-owner@vger.kernel.org
Received: from xes-mad.com ([216.165.139.218]:19927 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753241AbaIHSut (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Sep 2014 14:50:49 -0400
Date: Mon, 8 Sep 2014 13:49:46 -0500 (CDT)
From: Andrew Martin <amartin@xes-inc.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <2037985632.307306.1410202186698.JavaMail.zimbra@xes-inc.com>
In-Reply-To: <CAHQdGtT3iwdTXB3ecKSbao=yErOzv8NREPta1A5mOtwYxmRb8Q@mail.gmail.com>
References: <2124227602.386654.1409868802614.JavaMail.zimbra@xes-inc.com> <584874869.387720.1409869399398.JavaMail.zimbra@xes-inc.com> <CAHQdGtT3iwdTXB3ecKSbao=yErOzv8NREPta1A5mOtwYxmRb8Q@mail.gmail.com>
Subject: Re: Clarification on client "async" option
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> > This shows that a temporary filename is written and then closed, however
> > the
> > file is then chmodded and renamed to the final destination filename. Do the
> > chmod(2) and rename(2) calls force a COMMIT to be sent, flushing these
> > changes
> > to stable storage on the NFS server? Or, is there a possibility that during
> > a
> > power failure of both client and server, the file would remain as
> > .dest.y4ihWF
> > on the server?
> 
> In NFSv3, the close() will cause the client to flush all data to stable
> storage.
> The client will also flush data to stable storage on a chmod, since
> that could potentially affect its ability to write back the data. It
> will not bother to do so for rename.
> An application should normally be able to rely on the data being
> safely on disk in both these situations provided that the server
> honours the NFS protocol (with a caveat that an ill-timed 'kill -9'
> could interrupt the process of flushing).
> 
> All metadata operations such as create, chmod, rename, etc. will cause
> the server to flush the file metadata to disk assuming that you set
> the (highly recommended) "sync" export option. If "sync" is set, the
> server will also honour COMMIT requests by flushing the data to stable
> storage.

Thanks for the clarification - I will use "sync" on the server side and
"async" on the client side, since I know now that this combination will
provide both data and metadata safety.

Andrew
