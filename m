From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Mon, 8 Dec 2008 14:31:58 -0500
Message-ID: <69B1A7DB-F07E-4298-85A0-5259AC8A6286@oracle.com>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net> <493D253C.2040809@RedHat.com> <20081208150219.GB12390@uio.no> <493D74E8.8050908@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:60598 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbYLHTcZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Dec 2008 14:32:25 -0500
In-Reply-To: <493D74E8.8050908-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 8, 2008, at Dec 8, 2008, 2:26 PM, Steve Dickson wrote:
> Steinar H. Gunderson wrote:
>> On Mon, Dec 08, 2008 at 08:46:36AM -0500, Steve Dickson wrote:
>>> typedef struct {
>>>    char **hostname;
>>>    struct sockaddr_in saddr;
>>>    struct pmap pmap;
>>> } clnt_addr_t;
>>>
>>> Why isn't saddr a struct sockaddr instead of a struct sockaddr_in?
>>>
>>> It seems at the beginning of each routine saddr is always being
>>> typecast into a struct sockaddr pointer.... So wouldn't be easier
>>> and cleaner to simply make sadd a struct sockaddr or am I missing
>>> something?
>>
>> I'm sure most people here know this, but still, be careful: If you  
>> ever
>> intend to store an IPv6 address somewhere, the field in the struct  
>> should be
>> a sockaddr_storage. sockaddr (or sockaddr_in, for that matter) is  
>> not big
>> enough to store a sockaddr_in6.
> Understood... But isn't a struct sockaddr large enough to store
> a IPv6 address?

No, they aren't: IPv6 addresses are larger than sockaddr_in's.   
sockaddr's happen to be the same size as sockaddr_in's.  I think this  
is defined by POSIX, but I could be incorrect.

> Its no biggie... but what caught my eye was usually
> struct sockaddr are typecast into sockaddr_in, not the other away  
> around.


-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
