From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [NFS] sync, async, write speeds.
Date: Wed, 17 Sep 2008 10:36:25 -0500
Message-ID: <76bd70e30809170836t17a46227mf84c92e0fc80c8b3@mail.gmail.com>
References: <215ff4410809170035s38183fe3r51aeea62939b6327@mail.gmail.com>
	<48D0DCC9.3090208@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chris Fanning <christopher.fanning@gmail.com>,
	nfs@lists.sourceforge.net
To: "Shehjar Tikoo" <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:53791 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbYIQPgo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2008 11:36:44 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Kfz57-0003cn-R2
	for linux-nfs@vger.kernel.org; Thu, 18 Sep 2008 01:36:41 +1000
In-Reply-To: <48D0DCC9.3090208-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 17, 2008 at 5:32 AM, Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org> wrote:
>> If I change the export to async, it improves a lot.
> If you can assure uninterrupted power to the server, I dont see any
> reason why you cant use the "async" option.

If the server O/S crashes due to a bug, you are still open to silent
data corruption.  A UPS cannot help you with that.

--
Chuck Lever

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

