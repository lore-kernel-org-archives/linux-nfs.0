Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esa9.utexas.iphmx.com ([216.71.150.155]:20442 "EHLO
        esa9.utexas.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750914AbeC0TlF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 15:41:05 -0400
Subject: Re: [PATCH 1/2] [pynfs] remove redundant ply, gssapi and rpcgen.py
 modules
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Jianhong.Yin" <yin-jianhong@163.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org, Jianhong Yin <jiyin@redhat.com>
References: <20180327172709.13071-1-yin-jianhong@163.com>
 <20180327183725.GA22077@fieldses.org>
 <fc72ad79-c558-f6bb-fa96-870ba522a427@math.utexas.edu>
 <20180327193236.GB22077@fieldses.org>
From: Patrick Goetz <pgoetz@math.utexas.edu>
Message-ID: <ea96f87a-5838-5ce0-4c78-379641a4450b@math.utexas.edu>
Date: Tue, 27 Mar 2018 14:41:04 -0500
MIME-Version: 1.0
In-Reply-To: <20180327193236.GB22077@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/27/2018 02:32 PM, J. Bruce Fields wrote:
> Any reason not to change the README to recommend
> 
> 	pip install --user ply gssapi
> 
> ? Seems like the safer default.
> 

I'm not sure why you have a --user in there; this would be used to 
install packages for a specific user AFAIK.


