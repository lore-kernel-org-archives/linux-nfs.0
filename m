From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [RFC] new client gssd upcall
Date: Fri, 13 Jun 2008 18:50:37 -0400
Message-ID: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43966 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755998AbYFMWuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 18:50:44 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client needs a new more estensible text-based upcall to gssd, to
make it easier to support some features that are needed for new krb5
enctypes, for callbacks, etc.

We will have to continue to support the old upcall for backwards
compatibility with older gssd's.  To simplify upgrades, as well as
testing and debugging, it would help if we can upgrade gssd without
having to choose at boot (or module-load) time whether we want the new
or the old upcall.

That means that when gssd opens an rpc upcall pipe, we'd like to just
start using whichever version it chose immediately--ideally without
having to wait the 30 seconds that it would normally take for upcalls
already queued on the wrong upcall pipe to time out.

The following patches do that by queueing the upcalls on whichever of
the two upcall pipes (the new one and the old one) that somebody holds
open.  If nobody's opened anything yet, then upcalls are provisionally
queued on the new pipe.  I add a pipe_open method to allow the gss code
to keep track of which pipe is open, to prevent anyone from attempting
to open both pipes at once, and to cancel any upcalls that got queued to
the wrong pipe.

I did some minimal testing with the old upcall, but haven't tested the
new upcall yet.  (Olga, could you do that?)  So this is just an RFC at
this point.

--b.
