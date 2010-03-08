From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Problems with crossmnt since 1.2.1
Date: Mon, 08 Mar 2010 15:28:18 -0500
Message-ID: <4B955DE2.7080602@RedHat.com>
References: <20100228100643.GG26178@teal.hq.k1024.org> <20100301204010.GE23539@fieldses.org> <20100301211306.GA16341@teal.hq.k1024.org> <20100302032002.GA29212@fieldses.org> <20100307195449.GE9237@teal.hq.k1024.org> <20100307200607.GA13006@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798Ab0CHU2Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 15:28:24 -0500
In-Reply-To: <20100307200607.GA13006@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/07/2010 03:06 PM, J. Bruce Fields wrote:
> On Sun, Mar 07, 2010 at 08:54:49PM +0100, Iustin Pop wrote:
>> Sorry for the delayed response. I can confirm this solves my test case. I get
>> the right mount options in both the "mount directly the sub-directory" case,
>> and in the "mount parent and access the sub-directory via the crossmnt feature"
> 
> Excellent, thanks.  Steve, could you apply the following patches?
> 
> Also available from
> 
> 	git pull git://linux-nfs.org/~bfields/nfs-utils.git crossmnt-fixes
I think I will wait on commit 72f6d0 until it hashed out... 

steved.

