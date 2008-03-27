From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 1/1] silence-call-timeout-printk
Date: Thu, 27 Mar 2008 16:36:50 -0400
Message-ID: <EXNANE01kO22ZhCl8ai000001cd@exnane01.hq.netapp.com>
References: <1206643752-11132-1-git-send-email-aglo@umich.edu>
 <20080327195445.GI32540@fieldses.org>
 <1206648229.15396.2.camel@heimdal.trondhjem.org>
 <20080327202331.GJ32540@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Olga Kornievskaia <aglo@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10782 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755225AbYC0Uhf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2008 16:37:35 -0400
In-Reply-To: <20080327202331.GJ32540@fieldses.org>
References: <1206643752-11132-1-git-send-email-aglo@umich.edu>
 <20080327195445.GI32540@fieldses.org>
 <1206648229.15396.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
 <20080327202331.GJ32540@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Let me get this straight. You are suggesting that bringing back
cl_chatty as cl_quiet, in order to print messages when the
server's callback client can't talk to the client's callback server,
makes things clear? ;-)

Oh, my head does hurt. :-) :-)

Seriously, it sounds okay but printk isn't exactly the best means
for a server to tell people something doesn't work. The issue I see
is that clients will lose a delegation, data corruption may result,
and the only hint is a message in the server's log? Maybe I'm still
having trouble with the first question.

Tom.

At 04:23 PM 3/27/2008, J. Bruce Fields wrote:
>On Thu, Mar 27, 2008 at 04:03:49PM -0400, Trond Myklebust wrote:
>> On Thu, 2008-03-27 at 15:54 -0400, J. Bruce Fields wrote:
>> > On Thu, Mar 27, 2008 at 02:49:12PM -0400, Olga Kornievskaia wrote:
>> > > When the client's callback server goes away, the server's callback client
>> > > tries to contact the server and times out. For nfsd, it is beneficial to
>> > > printout a message when the client is unable to contact the server. For
>> > > the callback server, the same message is printed yet it is really not
>> > > an error. Thus we need a way to silence the message for the callback 
>> > > and yet print it for other cases.
>> 
>> Bring, back,
>> Bring, back,
>> Oh, bring back my cl_chatty to me...
>> 
>>   
>http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=com
>mitdiff;h=f518e35aec984036903c1003e867f833747a9d79
>
>OK, OK, so, shall we apply a patch that basically just reverts Chuck's
>patch there, except that it inverts the meaning and uses the name
>cl_quiet instead of cl_chatty?  (On the theory that since the verbose
>case is the common case, it's best to let this thing be initialized to 0
>and only make the callback code mess with it?)  Or are you nostalgic for
>cl_chatty?
>
>--b.
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

