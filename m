From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: how to parse the 64byte NFSv3 file handle
Date: Mon, 19 May 2008 10:36:54 -0400
Message-ID: <8762271D-9645-49DF-B218-E626F704DC96@oracle.com>
References: <483136FC.4050208@ncic.ac.cn> <483140C4.3010104@panasas.com> <RTPCLUEXC1-PRDpAOAk000000fd@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Benny Halevy <bhalevy@panasas.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Thomas Talpey <Thomas.Talpey@netapp.com>
To: xing jing <xingjing-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:58498 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758152AbYESOmv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 10:42:51 -0400
In-Reply-To: <RTPCLUEXC1-PRDpAOAk000000fd-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 19, 2008, at 7:08 AM, Talpey, Thomas wrote:
> At 04:56 AM 5/19/2008, Benny Halevy wrote:
>> On May. 19, 2008, 11:14 +0300, xing jing <xingjing-3pZTqkFmMFknDS1+zs4M5A@public.gmane.org> wrote:
>>> recently, I want to get some information (like file access patten)
>>> from a trace of NFS client. The simplest way may be parse the file
>>> handle to get the file ino and directory ino, but I don't know how  
>>> to
>>> get them from the 64 of 16 hexadecimal. Can you tell me how to parse
>>> file handle to get useful information, thanks very much.
>>
>> That file handle contents are opaque to the client so you'd
>> need to have the server's code or reverse engineer its
>> structure.
>
> Wireshark understands the format of many NFS server filehandles. You
> can simply zoom-in on the filehandle in the details pane to see much  
> of
> this. Alternatively, you can look back in the trace to find the LOOKUP
> or READDIR/READDIRPLUS to find the mapping between name and
> filehandle.
>
> By the way, not all filehandles are 64 bytes. That, too, is a server- 
> specific choice.

Wireshark has the ability to sniff filehandles from certain server  
types.  I believe both Linux server file handles and NetApp file  
handles are supported.  You need to set this in the preference pane  
for the NFS decoder, it won't try to discover which server type you  
use automatically.  Otherwise it will treat file handles as entirely  
opaque.

Also, there is a checkbox in the NFS decoder preference pane for  
enabling wireshark to associated file handles with file names and  
display the file names where appropriate.
The checkbox is "Snoop FH to filename mappings".

>
>
> Tom.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



