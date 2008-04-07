From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS3+KRB5 question
Date: Mon, 7 Apr 2008 14:00:51 -0400
Message-ID: <20080407180051.GE3305@fieldses.org>
References: <35b652ed9c3ac37ca9dc102b1bb65a83@localhost> <20080401123643.GA18475@goelette.ens.fr> <20080401205629.GC21343@fieldses.org> <2A8F26C5-13E7-47F0-AC04-33820FF9377A@it-loops.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Guntsche Michael <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38210 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097AbYDGSAw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Apr 2008 14:00:52 -0400
In-Reply-To: <2A8F26C5-13E7-47F0-AC04-33820FF9377A-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 03, 2008 at 10:43:22PM +0200, Guntsche Michael wrote:
>
> On Apr 1, 2008, at 22:56, J. Bruce Fields wrote:
>> The client here is within its rights, and the server is wrong; see:
>>
>> 	http://www.ietf.org/rfc/rfc2623.txt
>>
>> (especially 2.3.2, "NFS Procedures Used at Mount Time").  The kernel
>> changes on the server side should not be too difficult after the  
>> export
>> changes we made a few versions ago.
>
> Hi,
>
> Thanks for the info, is it planned to change the server part in the near 
> future, or is this a low priority task, just curious.

It's on my todo list, but I don't know when I'm going to get to it.

--b.
