Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:47670 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162Ab2ALVCY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 16:02:24 -0500
Received: by werm1 with SMTP id m1so1713220wer.19
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2012 13:02:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120112155433.6e2a859b@tlielax.poochiereds.net>
References: <CAE9DZUQTFA8qqNtphJe6NQYqbbdi_8aMyDBgbJF1-=1arW3rCw@mail.gmail.com>
	<20120112155433.6e2a859b@tlielax.poochiereds.net>
Date: Thu, 12 Jan 2012 15:02:23 -0600
Message-ID: <CAE9DZUSBwX1E-yqRw=ia7WQ8BxLWrDdhqiAB6VSL=QxUwxKkXw@mail.gmail.com>
Subject: Re: Problems restarting nfsd
From: Dallas Clement <dallas.a.clement@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 111 is -ECONNREFUSED. Looks like the portmapper or rpcbind is refusing
> connections?

Yes, that's right.  I did a bit of google searching and it seems that
some folks have gotten past this problem by replacing portmapper with
rpcbind.
