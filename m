Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:12084 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884Ab3AXE35 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 23:29:57 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Dave Quigley <dpquigl@davequigley.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "Linux NFS Mailing list" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 01/14] Security: Add hook to calculate context based on
 a negative dentry.
Date: Thu, 24 Jan 2013 04:29:54 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA918333F8D@sacexcmbx05-prd.hq.netapp.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
  <1358862042-27520-2-git-send-email-steved@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91833244F@sacexcmbx05-prd.hq.netapp.com>
 <5100AF22.7070403@davequigley.com>
In-Reply-To: <5100AF22.7070403@davequigley.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 23, 2013, at 10:48 PM, Dave Quigley <dpquigl@davequigley.com>
 wrote:

> On 1/23/2013 1:31 PM, Myklebust, Trond wrote:
>> On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
>>> From: David Quigley <dpquigl@davequigley.com>
>>> 
>>> There is a time where we need to calculate a context without the
>>> inode having been created yet. To do this we take the negative dentry and
>>> calculate a context based on the process and the parent directory contexts.
>>> 
>>> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
>>> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
>>> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
>>> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
>>> ---
>>>  include/linux/security.h | 27 +++++++++++++++++++++++++++
>>>  security/capability.c    |  8 ++++++++
>>>  security/security.c      | 10 ++++++++++
>>>  security/selinux/hooks.c | 35 +++++++++++++++++++++++++++++++++++
>>>  4 files changed, 80 insertions(+)
>> 
>> Linus won't accept a patch that changes the security code from Bruce or
>> myself without acks from the security maintainers. I assume that means
>> we need to get at least an ack from James Morris, and then possibly
>> Stephen and Eric too...
>> 
>> 
> 
> I have an email from James Morris saying that the changes should go through your tree. Should I get him to ack these patches so you can pass them through?
> 
> Dave


Please do, yes. Otherwise Linus will usually delay the pull while he asks for one.

Cheers
  Trond