Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cavspool01.kulnet.kuleuven.be ([134.58.240.41]:57604 "EHLO
	cavspool01.kulnet.kuleuven.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753006Ab1DUHaj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Apr 2011 03:30:39 -0400
Received: from cavuit01.kulnet.kuleuven.be (cavuit01.kulnet.kuleuven.be [134.58.240.43])
	by cavspool01.kulnet.kuleuven.be (Postfix) with ESMTP id A3F46167391
	for <linux-nfs@vger.kernel.org>; Thu, 21 Apr 2011 09:26:01 +0200 (CEST)
Message-ID: <4DAFDBC6.60700@esat.kuleuven.be>
Date: Thu, 21 Apr 2011 09:24:54 +0200
From: Rik Theys <Rik.Theys@esat.kuleuven.be>
To: bfields@fieldses.org
CC: linux-nfs@vger.kernel.org
Subject: Re: Open with O_CREAT flag set fails to open existing files on non
 writable directories
In-reply-to: 20110420152324.GB15919@fieldses.org
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

 >> The patch adds a conditional statement to check for create permissions
 >> only if the file doesn't exist.

 > That looks correct to me, thanks.

 > It's a bad bug, but appears to be one we've lived with a long time, so
 > I'm a bit up in the air whether to submit now for 2.6.39 or to queue up
 > for 2.6.40.

As an administrator who is hit by this bug on a daily basis, I would 
like it to reach 2.6.39. But as I filed the bug, I guess I'm biased :-).

Distributions would like to see this accepted upstream before they 
consider backporting the fix to their current stable releases.


Regards,

Rik
