From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Tue, 09 Dec 2008 14:17:00 -0500
Message-ID: <493EC42C.2080901@RedHat.com>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net> <493D253C.2040809@RedHat.com> <2DC7493B-E0E5-43C8-8FD1-A9C0C5EFA821@oracle.com> <493DA5EC.5090805@RedHat.com> <20081208232816.GA18856@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43417 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752677AbYLITTT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2008 14:19:19 -0500
In-Reply-To: <20081208232816.GA18856-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Steinar H. Gunderson wrote:
> On Mon, Dec 08, 2008 at 05:55:40PM -0500, Steve Dickson wrote:
>> Yes... one does pass pointers of struct sockaddr to the majority 
>> of the network system call such as bind().. but conventionally 
>> I've seen a lot of declare struct sockaddr as memory then typecasting 
>> that memory into a struct sockaddr_in pointer...
> 
> That's just wrong. Don't do that :-) (Where have you seen this, by the way?)
I believe all over the RPC code in the glibc... for one place...
I have not looked at that code for a while so maybe I have
it backwards... 

steved.
