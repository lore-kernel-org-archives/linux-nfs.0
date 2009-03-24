From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: Removed a number of warn_unused_result warnings
Date: Tue, 24 Mar 2009 12:56:35 -0400
Message-ID: <49C910C3.2090700@RedHat.com>
References: <49C797C6.8030102@RedHat.com> <654687AD-E743-45A4-99B1-BBBEAA5D915D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43964 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760398AbZCXQ72 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Mar 2009 12:59:28 -0400
In-Reply-To: <654687AD-E743-45A4-99B1-BBBEAA5D915D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> I've actually already addressed all the cases you found under
> utils/statd/... my re-writes replace both nsm_log() and note() with
> calls to xlog(), and add return code checking to the write(2) calls.
Sorry about that... but I already did the commit... since I wanted to
get some testing asap..  so go head and send me the parts I broke 
and I will do the forward port...

> 
> Also, note that you can use the "%m" format specifier to generate the
> same string you get from strerror(errno).
Yeah.. I knew that... but I thought there some memory corruption 
or service denial issue with using "%m" so I've always stuck
with '%d (%s)'.


steved.
