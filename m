From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: make --enable-tirpc the default when configuring
Date: Mon, 22 Jun 2009 10:35:58 -0400
Message-ID: <4A3F96CE.3090103@RedHat.com>
References: <1244466232-947-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
	Dan.Muntz@netapp.com, vapier@gentoo.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60677 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750931AbZFVOjG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jun 2009 10:39:06 -0400
In-Reply-To: <1244466232-947-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Jeff Layton wrote:
> Make --enable-tirpc the default. If --enable-tirpc wasn't explicitly
> specified, but TIRPC libs or headers aren't present then just throw a
> warning and disable it. If it was explicitly specified, then throw an
> error and exit if they aren't present.
> 
Committed...

steved.
