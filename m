Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:57125 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923Ab1HQP2G convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2011 11:28:06 -0400
Subject: Re: Expected response from server not supporting v4
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E4B6134.7000903@gluster.com>
Date: Wed, 17 Aug 2011 11:27:49 -0400
Cc: Steve Dickson <SteveD@redhat.com>, <linux-nfs@vger.kernel.org>
Message-Id: <4B79A89A-6511-4447-976A-924670409438@oracle.com>
References: <4E4A23E2.3020103@gluster.com> <4E4A67AE.8040305@RedHat.com> <4E4B6134.7000903@gluster.com>
To: Shehjar Tikoo <shehjart@gluster.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 17, 2011, at 2:35 AM, Shehjar Tikoo wrote:

> Steve Dickson wrote:
>> On 08/16/2011 04:01 AM, Shehjar Tikoo wrote:
>>> Hi All
>>> 
>>> The following thread discusses the behaviour when the client does not support v4:
>>> http://thread.gmane.org/gmane.linux.nfs/36928/
>>> 
>>> OTOH, when the server does not support v4, for eg. Gluster NFS server, where we support only v3, I believe v4 client will attempt to connect directly to port 2049 and receive connection failure errors on TCP. Does the current nfs client handle the situation where this results in a timeout for mount? We're hearing  a report of a timeout occurring on the RHEL6 client because the server does not have v4 support. Could someone please shed some light on how this behaviour is handled at present? Thanks
>> Here is the current logic as to what will cause a fall back:
>>    switch (errno) {
>>    case EPROTONOSUPPORT:
>>        /* A clear indication that the server or our
>>         * client does not support NFS version 4. */
>>        goto fall_back;
>>    case ENOENT:
>>        /* Legacy Linux servers don't export an NFS
>>         * version 4 pseudoroot. */
>>        goto fall_back;
>>    case EPERM:
>>        /* Linux servers prior to 2.6.25 may return
>>         * EPERM when NFS version 4 is not supported. */
>>        goto fall_back;
>>    default:
>>        return result;
>>    }
>> fall_back:
>>    return nfs_try_mount_v3v2(mi);
>> So in the case of the Gluster server, you are dropping into the
>> default case which is causing the time out.
>> In the above patch set, Mi patches the mount code to fall back on EINVAL which is the current return value from the kernel, when v4 is not configured. I'm not totally against doing something like this, but this is very touchy  code since it could have negative effects on other legacy servers.
>> So I'm thinking Mi's kernel patch that cause the kernel
>> to return EPROTONOSUPPORT, which is the correct return
>> value, is probably the better way to go... 
> 
> Thanks Steve. My understanding is that Mi's patch is to handle the case where the client does not support v4. Do you think the same patch will also handle a server that does not support v4 and hence prevents a client from connecting to 2049?

It's a best practice for clients to connect to 2049 immediately, rather than querying the server's portmapper, to discover and potentially connect to a server's NFSv4 service.

A full-frame network trace of a mount attempt that times out would tell us if there is something pathological going on.

>> With that said, to get this type of functionality into
>> already released distros, maybe the mount patch should be looked into since it much easier to back port and people are more will to take nfs-utils updates than kernel updates... So, if by chance, a well place bz is opened against an already released distro, someone would have to make that call... ;-) steved.
>>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




