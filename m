From: Steve Dickson <SteveD@redhat.com>
Subject: Re: How to control the order of different export options for different
 client formats?
Date: Tue, 07 Jun 2011 16:33:17 -0400
Message-ID: <4DEE8B0D.5040500@RedHat.com>
References: <4DD2A084.1040905@moving-picture.com> <20110518080106.1159c5b8@notabene.brown> <4DD39D39.7010805@moving-picture.com> <20110518162050.GB16835@fieldses.org> <4DD66EC6.7090706@moving-picture.com> <20110520164147.GA11176@fieldses.org> <4DE79236.1080808@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756561Ab1FGUdV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 16:33:21 -0400
In-Reply-To: <4DE79236.1080808-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/02/2011 09:37 AM, James Pearson wrote:
> J. Bruce Fields wrote:
>>
>> But could we just combine this with the previous section--and make sure
>> the different possibilities are listed there in the correct priority
>> order to start off with.
>>
>> That'd also mean adding a new subsection for the "anonymous" case.
> 
> OK - how about the attached patch?
> 
> James Pearson
Committed....

steved.
