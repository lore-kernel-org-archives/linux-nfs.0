Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50944 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754767Ab2CPVW4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 17:22:56 -0400
Received: from compute2.internal (compute2.nyi.mail.srv.osa [10.202.2.42])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 9041B216A6
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 17:22:55 -0400 (EDT)
Message-ID: <4F63AF2B.5080307@fastmail.fm>
Date: Fri, 16 Mar 2012 22:22:51 +0100
From: Bernd Schubert <bernd.schubert@fastmail.fm>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        "J. Bruce Fields" <bfields@redhat.com>, "Ted Ts'o" <tytso@mit.edu>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int may_flags'
 in nfsd_open()
References: <20120309205148.GB5635@thunk.org> <20120312150912.GB12440@thunk.org> <20120312154921.GB17153@pad.fieldses.org> <20120312222250.GD8991@fieldses.org> <20120313200117.GA21991@fieldses.org> <4F5FA827.8020606@itwm.fraunhofer.de> <20120313203446.GB21991@fieldses.org> <4F5FB771.9010805@fastmail.fm> <20120313212947.GK31995@pad.fieldses.org> <4F60AC0D.9020204@itwm.fraunhofer.de> <20120314160529.GB31194@fieldses.org>
In-Reply-To: <20120314160529.GB31194@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/14/2012 05:05 PM, J. Bruce Fields wrote:
> On Wed, Mar 14, 2012 at 03:32:45PM +0100, Bernd Schubert wrote:
>> shall I sent an updated version of the previous ext4 patch
>> or is this patch sufficient?
>
> Up to Ted.
>
> Ted, I haven't published my merge of your branch, so at least for my
> purposes I don't care whether you fold this in or pop another patch on
> top.

Ted, could you please tell me how to proceed?


Thanks,
Bernd
