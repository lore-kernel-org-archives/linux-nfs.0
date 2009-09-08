From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] support "-t nfs -o vers=4" [take 3]
Date: Tue, 08 Sep 2009 17:11:59 -0400
Message-ID: <4AA6C89F.1030801@RedHat.com>
References: <20090908210012.3326.57767.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751662AbZIHVL6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 17:11:58 -0400
In-Reply-To: <20090908210012.3326.57767.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/08/2009 05:02 PM, Chuck Lever wrote:
> Hi Steve-
> 
> These changes accompany kernel support for "-t nfs -o vers=4".
> 
> One patch description was clarified, and a bug was fixed in the last
> patch of this series.
> 
I'm a bit concern about committing these since its not clear which 
kernel the supporting patches will be in... Why document something
that does not work... 

steved.
