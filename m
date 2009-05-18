From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: Virtual IPs and blocking locks
Date: Mon, 18 May 2009 07:55:44 -0600
Message-ID: <4A1168E0.3090409@hp.com>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com> <4A11657B.4070002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Sachin S. Prabhu" <sprabhu@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:21065 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbZERNyX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 May 2009 09:54:23 -0400
In-Reply-To: <4A11657B.4070002@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client gets a message from an IP address that he never sent a 
request to, he is correct to reject that message.

Rob


Sachin S. Prabhu wrote:
>
> However this still leaves the question of the client handling such a situation 
> where a callback is made from a different ip address. Should the client accept 
> such callbacks or is the current behaviour of rejecting these callbacks correct?

