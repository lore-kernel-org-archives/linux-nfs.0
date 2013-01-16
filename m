Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756332Ab3APVPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2013 16:15:48 -0500
Message-ID: <50F71032.4070705@RedHat.com>
Date: Wed, 16 Jan 2013 15:40:18 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Hemmo Nieminen <hemmo.nieminen@iki.fi>
CC: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH] Binding a privileged port in rpc.statd.
References: <20130110142710.GA2544@fcku.lan>
In-Reply-To: <20130110142710.GA2544@fcku.lan>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/01/13 09:27, Hemmo Nieminen wrote:
> Hi,
> 
> It seems that rpc.statd will fail to bind to a (free) port, if
> the first port it receives is listed in /etc/services. The
> bindresvport will keep on returning the same port if we close
> the socket too early.
> 
> The attached patch should fix this.
> 
Committed....

steved.
