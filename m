Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:3744 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758353Ab1JGCzR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Oct 2011 22:55:17 -0400
Date: Thu, 6 Oct 2011 22:55:01 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>,
        nfsv4 <nfsv4@ietf.org>
Message-ID: <953639179.163.1317956101014.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1988930626.161.1317955756425.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: [nfsv4] back channel flags, CREATE_SESSION,
 BIND_CONN_TO_SESSION
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I appreciate your point of view.  I appreciate Rick's comments.  I hope some other comments will trickle in.  Do I think you and Rick are saying the same thing?  Not really.  Do I think you're making sense when you imply I want to change the standard?  No, I don't follow that.  BIND_CONN_TO_SESSION is in the published standard.  Can I show a dedicated back channel improves performance?  Not at present.  That's a sensible question.  I think if the protocol in general is doing what it is intended to do, it should be possible for some workloads, at some point.  (If callbacks are, somehow generally detrimental to performance, as you state, I think maybe we have some more work to do.)  (I note only one more thing--I did raise this topic on list 12 months ago.  Only Bruce commented, at the time.)

Thanks again,

Matt

-- 

Matt Benjamin

The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
