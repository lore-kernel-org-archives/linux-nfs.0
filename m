From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfsstat --sleep=#
Date: Thu, 12 Mar 2009 10:00:34 -0400
Message-ID: <ADDF97BC-8B6A-4EFC-9242-C1454B8F423C@oracle.com>
References: <49B86744.6060105@disney.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:50015 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755415AbZCLOAt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 10:00:49 -0400
In-Reply-To: <49B86744.6060105-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Kevin-

man watch(1)

On Mar 11, 2009, at Mar 11, 2009, 9:37 PM, Kevin Constantine wrote:

> I'd really like to have a way to output the nfsstat counters at  
> regular intervals (every 3 seconds) where the output is the  
> difference between 3 seconds ago and now.  Frequently I'll run a  
> test and want to watch the nfs call profile throughout the course of  
> the test.
>
> Does something like this already exist?
> Are there objections to seeing a feature like this?
>
> I'm thinking something like:
> nfsstat --sleep=1
>
> nfs v3 call:   Server   Client
>       total:        0     3476
>        null:        0        0
>     getattr:        0     1679
>     setattr:        0        0
>      lookup:        0      839
>      access:        0      839
>    readlink:        0        0
>        read:        0        0
>       write:        0        0
>      create:        0        0
>       mkdir:        0        0
>     symlink:        0        0
>       mknod:        0        0
>      remove:        0        0
>       rmdir:        0        0
>      rename:        0        0
>        link:        0        0
>     readdir:        0        0
> readdirplus:        0        0
>      fsstat:        0      119
>      fsinfo:        0        0
>    pathconf:        0        0
>      commit:        0        0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




