From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Mon, 08 Dec 2008 14:26:32 -0500
Message-ID: <493D74E8.8050908@RedHat.com>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net> <493D253C.2040809@RedHat.com> <20081208150219.GB12390@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38820 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076AbYLHT2u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2008 14:28:50 -0500
In-Reply-To: <20081208150219.GB12390-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Steinar H. Gunderson wrote:
> On Mon, Dec 08, 2008 at 08:46:36AM -0500, Steve Dickson wrote:
>> typedef struct {
>>     char **hostname;
>>     struct sockaddr_in saddr;
>>     struct pmap pmap; 
>> } clnt_addr_t;
>>
>> Why isn't saddr a struct sockaddr instead of a struct sockaddr_in?
>>
>> It seems at the beginning of each routine saddr is always being
>> typecast into a struct sockaddr pointer.... So wouldn't be easier
>> and cleaner to simply make sadd a struct sockaddr or am I missing
>> something?
> 
> I'm sure most people here know this, but still, be careful: If you ever
> intend to store an IPv6 address somewhere, the field in the struct should be
> a sockaddr_storage. sockaddr (or sockaddr_in, for that matter) is not big
> enough to store a sockaddr_in6.
Understood... But isn't a struct sockaddr large enough to store
a IPv6 address? Its no biggie... but what caught my eye was usually 
struct sockaddr are typecast into sockaddr_in, not the other away around.

steved.

