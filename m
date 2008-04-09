From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] rpc: bring back cl_chatty
Date: Wed, 9 Apr 2008 15:01:43 -0400
Message-ID: <C3EA9DD1-FA3D-44E0-BCC2-52A0E933FA31@oracle.com>
References: <20080408204856.GA21966@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org,
	aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:57778 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbYDITka (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Apr 2008 15:40:30 -0400
In-Reply-To: <20080408204856.GA21966@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 8, 2008, at 4:48 PM, J. Bruce Fields wrote:
> From: Olga Kornievskaia <aglo@citi.umich.edu>
>
> The cl_chatty flag alows us to control whether a given rpc client  
> leaves
>
> 	"server X not responding, timed out"
>
> messages in the syslog.  Such messages make sense for ordinary nfs
> clients (where an unresponsive server means applications on the
> mountpoint are probably hanging), but not for the callback client  
> (which
> can fail more commonly, with the only result just of disabling some
> optimizations).
>
> Previously cl_chatty was removed, do to lack of users; reinstate  
> it, and
> use it for the nfsd's callback client.

Actually, this might be another candidate for "fail the request  
immediately if the transport can't connect."

When exactly do these "server not responding" messages come out?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
