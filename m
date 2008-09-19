From: "Chris Fanning" <christopher.fanning@gmail.com>
Subject: Re: [NFS] sync, async, write speeds.
Date: Fri, 19 Sep 2008 09:40:00 +0200
Message-ID: <215ff4410809190040w424d2cc2sd1e119a90d64cc6d@mail.gmail.com>
References: <215ff4410809170035s38183fe3r51aeea62939b6327@mail.gmail.com>
	<48D0DCC9.3090208@cse.unsw.edu.au>
	<76bd70e30809170836t17a46227mf84c92e0fc80c8b3@mail.gmail.com>
	<215ff4410809180122o3141a5f5h6e93e092abf07fd1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
To: "Chuck Lever" <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57604 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750876AbYISHkK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2008 03:40:10 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Kgab1-0007Qf-DL
	for linux-nfs@vger.kernel.org; Fri, 19 Sep 2008 17:40:07 +1000
In-Reply-To: <215ff4410809180122o3141a5f5h6e93e092abf07fd1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

> I'm going to try jumbo frames but it'll take me a while to set it up.
> I'll get back to you with the results.
>
Meanwhile I've been thinking about this. Please excuse my ignorance.
Jumbo frames are changes at ethernet level2 but nfs is at ip level3. right?
If I've been getting reasonable results using async, doesn't this
indicate that my ethernet network is fast enough already? How will
Jumbo frames help to solve the 'sync' issue?

Thanks.
Chris.

> Thanks.
> Chris.
>
> On Wed, Sep 17, 2008 at 5:36 PM, Chuck Lever <chucklever@gmail.com> wrote:
>> On Wed, Sep 17, 2008 at 5:32 AM, Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org> wrote:
>>>> If I change the export to async, it improves a lot.
>>> If you can assure uninterrupted power to the server, I dont see any
>>> reason why you cant use the "async" option.
>>
>> If the server O/S crashes due to a bug, you are still open to silent
>> data corruption.  A UPS cannot help you with that.
>>
>> --
>> Chuck Lever
>>
>

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

