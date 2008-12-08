From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Mon, 8 Dec 2008 18:38:23 -0500
Message-ID: <65E633E6-B1BE-4372-8F17-5F19DD05D552@oracle.com>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net> <493D253C.2040809@RedHat.com> <2DC7493B-E0E5-43C8-8FD1-A9C0C5EFA821@oracle.com> <493DA5EC.5090805@RedHat.com> <20081208232816.GA18856@uio.no>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:32336 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426AbYLHXkS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Dec 2008 18:40:18 -0500
In-Reply-To: <20081208232816.GA18856-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 8, 2008, at Dec 8, 2008, 6:28 PM, Steinar H. Gunderson wrote:
> On Mon, Dec 08, 2008 at 05:55:40PM -0500, Steve Dickson wrote:
>> Yes... one does pass pointers of struct sockaddr to the majority
>> of the network system call such as bind().. but conventionally
>> I've seen a lot of declare struct sockaddr as memory then typecasting
>> that memory into a struct sockaddr_in pointer...
>
> That's just wrong. Don't do that :-) (Where have you seen this, by  
> the way?)

The server-side sysctl code defines a data structure shared between  
nfs-utils and the kernel which has some fields defined as type "struct  
sockaddr".  That code works because "struct sockaddr_in" and "struct  
sockaddr" happen to be the same size.

But it is incorrect.  Since those are legacy interfaces and only need  
to handle IPv4 addresses, they are not worth fixing at this point.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
