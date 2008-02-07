From: Luke Cyca <luke-rgTVnuQaENGakBO8gow8eQ@public.gmane.org>
Subject: Re: NFS+krb5: Failed to create krb5 context for user with uid 0
Date: Wed, 6 Feb 2008 17:20:14 -0800
Message-ID: <F6E1A865-CC8B-4286-B67B-3E36F610875B@zymeworks.com>
References: <1459814D-D960-44A2-947E-F6D0BD46DAC6@zymeworks.com> <4d569c330802052112q418ffc45u7e20dee3d2a393d7@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from s216-232-71-140.bc.hsia.telus.net ([216.232.71.140]:58372 "EHLO
	mail.zymeworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbYBGBUT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2008 20:20:19 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.zymeworks.com (Postfix) with ESMTP id 6FB78DA7C64
	for <linux-nfs@vger.kernel.org>; Wed,  6 Feb 2008 17:20:18 -0800 (PST)
Received: from mail.zymeworks.com ([127.0.0.1])
 by localhost (bartender.lan.zymeworks.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 27530-05 for <linux-nfs@vger.kernel.org>;
 Wed,  6 Feb 2008 17:20:15 -0800 (PST)
Received: from [192.168.1.25] (moonshine.lan.zymeworks.com [192.168.1.25])
	by mail.zymeworks.com (Postfix) with ESMTP id 1C429DA7C3A
	for <linux-nfs@vger.kernel.org>; Wed,  6 Feb 2008 17:20:15 -0800 (PST)
In-Reply-To: <4d569c330802052112q418ffc45u7e20dee3d2a393d7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 5, 2008, at 9:12 PM, Kevin Coffman wrote:
> If the Mac server code can support other encryption types like Triple
> DES and ArcFour, you shouldn't need to limit it to only the
> des-cbc-crc key.  The Linux nfs-utils code on the client should be
> limiting the negotiated encryption type to des.
>
> I would assume if normal users are able to get a context and talk to
> the server, that root using the keytab should be able to do so as
> well.


I added a principal for root/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org and added  
it to the client's keytab and everything appears to work now.

I then put the other keys back on the server's keytab as you suggested.

Thanks for the help!


Luke


Notice of Confidentiality: The information transmitted is intended only for the
person or entity to which it is addressed and may contain confidential and/or
privileged material. Any review, re-transmission, dissemination or other use of
or taking of any action in reliance upon this information by persons or entities
other than the intended recipient is prohibited. If you received this in error
please contact the sender immediately by return electronic transmission and then
immediately delete this transmission including all attachments without copying,
distributing or disclosing the same.


