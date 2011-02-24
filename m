Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:48353 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755520Ab1BXQtA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Feb 2011 11:49:00 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.72)
	(envelope-from <wferi@niif.hu>)
	id 1PseN8-0005SN-Cj
	for linux-nfs@vger.kernel.org; Thu, 24 Feb 2011 17:48:58 +0100
From: Ferenc Wagner <wferi@niif.hu>
To: linux-nfs@vger.kernel.org
Subject: Re: Seemingly inconsistent directory state under NFSv4
References: <87sjvuiwnl.fsf@tac.ki.iif.hu> <87d3mkhvgb.fsf@tac.ki.iif.hu>
	<20110223193929.GA13399@fieldses.org>
Date: Thu, 24 Feb 2011 17:48:58 +0100
In-Reply-To: <20110223193929.GA13399@fieldses.org> (J. Bruce Fields's message
	of "Wed, 23 Feb 2011 14:39:29 -0500")
Message-ID: <87vd098jk5.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Tue, Feb 22, 2011 at 05:42:44PM +0100, Ferenc Wagner wrote:
>> Ferenc Wagner <wferi@niif.hu> writes:
>> 
>>> In our somewhat mixed NFSv4 setup (Linux 2.6.32 Debian squeeze server, a
>>> 2.6.26 and a 2.6.32 Debian lenny client) we sometimes experience the
>>> following: removing a file on the 2.6.26 client makes that file
>>> disappear from the directory listing of the 2.6.32 client, but the file
>>> itself remains accessible by its old -- now nonexistent -- name there.
>>> Is such a confusing state expected, or is this the manifestation of some
>>> bug?
>> 
>> Is this perhaps a manifestation of the following paragraph of
>> nfs41-server.txt in the Linux kernel documentation?
>> 
>>     Incomplete delegation enforcement: if a file is renamed or
>>     unlinked, a client holding a delegation may continue to
>>     indefinitely allow opens of the file under the old name.
>> 
>> If yes, is there a way to list the active delegations (on the server and
>> on the client) and possibly trigger releasing/recalling them?
>
> The linux client will return any delegation before it does a rename or
> unlink, so if you're just doing everything from one client, I don't
> *think* the problem is with delegations--you should hit this delegation
> problem only in the case where you are removing the file on one client
> while using it on another, or removing on the server while using it on
> the client.
>
> (In the case of client-client conflicts, this is fixed in 2.6.38.)

One client removed the file, and another could still access it by name
(although not present in the directory listing).  So it could have been
a client-client conflict, even though we couldn't prove that the removed
file was actually in use on the client.  Is there a way to list the
delegations being hold by a client?

> You can turn off delegations completely with
> 	echo 0 >/proc/sys/fs/leases-enable
> before starting the nfs server.

Wouldn't I lose most of the efficiency advantages of NFSv4 with that
move?
-- 
Thanks,
Feri.
