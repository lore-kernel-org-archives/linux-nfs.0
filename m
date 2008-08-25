From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/5] NFS: Enable NFSv4 callback server to listen on
	AF_INET6 sockets
Date: Mon, 25 Aug 2008 18:48:05 -0400
Message-ID: <20080825224805.GA10175@fieldses.org>
References: <20080822163939.20488.92983.stgit@manray.1015granger.net> <20080822164201.20488.61180.stgit@manray.1015granger.net> <20080822231801.GA12995@fieldses.org> <76bd70e30808221934o22de4d51vca758957f565f256@mail.gmail.com> <2E06E166-E115-4EA0-A6BC-F10F76673482@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43890 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753737AbYHYWsJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2008 18:48:09 -0400
In-Reply-To: <2E06E166-E115-4EA0-A6BC-F10F76673482@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 25, 2008 at 12:16:00PM -0400, Chuck Lever wrote:
> On Aug 22, 2008, at Aug 22, 2008, 10:34 PM, Chuck Lever wrote:
>> On Fri, Aug 22, 2008 at 7:18 PM, J. Bruce Fields  
>> <bfields@fieldses.org> wrote:
>>> On Fri, Aug 22, 2008 at 12:42:02PM -0400, Chuck Lever wrote:
>>>> Allow the NFS callback server to listen for requests via an AF_INET6
>>>> or AF_INET socket.
>>>>
>>>> The NFS callback server determines the listener's address family  
>>>> from
>>>> the address the client uses to contact the server.  The server will
>>>> always call the client back using the same address family.
>>>
>>> Won't the server determine that from the callback address which the
>>> client provides in the setclientid?
>>
>> A client has to have IPv6 networking to mount an IPv6 server.
>> Otherwise both will use IPv4.  Do you think we should worry about the
>> case where a client provides a callback address in a different address
>> family from the server's address?

Oh!  I don't know.  If there's a choice then I'd think the server would
use whatever address family it thinks the address you sent it in the
cb_location field of the setclientid, but if you tell me it's impossible
for that situation to ever arise then I'll believe you....

>> But I suppose it would be more precise to call nfs_callback_up() using
>> the family of the passed-in clientaddr= mount option instead of the
>> passed-in addr= option.  That will require discovering the address
>> family of the clientaddr string.
>>
>> We could convert the clientaddr string into a sockaddr temporarily (we
>> don't already do that... it's converted into a universal address
>> string, but not into a sockaddr).
>
> I thought about this more over the weekend.
>
> We've got a similar problem here that we have with starting just a TCP  
> or UDP listener for lockd based on what transport protocols were  
> requested on the mount command line.
>
> The NFSv4 callback server (and lockd, and probably NFSD) should start  
> either a single AF_INET or a single AF_INET6 listener, not both.  Right 
> now, the callback server's address family is selected based on mount 
> options for the first mount request.  But we only want one of these 
> listeners for all mount points on a system, and it should be one that 
> covers all the needed address families, no matter which address family 
> was used during the first mount request.
>
> So these services need to start a listener not based on mount options,  
> but on what kind of networking is available on the host.  If IPV6 is  
> available in the kernel, I think, an AF_INET6 listener should be  
> started; otherwise, start an AF_INET listener.
>
> I think the only externally visible issue with doing this is how  
> addresses are presented in kernel log and error messages.  If the  
> functions which generate presentation format address strings are smart  
> enough to recognize a mapped IPv4 address and present it in dotted-quad 
> format, that should be enough.
>
> Thoughts/opinions?

I don't know.  I still haven't had a chance to learn about ipv6, so I
feel a bit at a loss.

--b.
