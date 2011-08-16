Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39680 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543Ab1HPMu4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2011 08:50:56 -0400
Message-ID: <4E4A67AE.8040305@RedHat.com>
Date: Tue, 16 Aug 2011 08:50:54 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Shehjar Tikoo <shehjart@gluster.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Expected response from server not supporting v4
References: <4E4A23E2.3020103@gluster.com>
In-Reply-To: <4E4A23E2.3020103@gluster.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/16/2011 04:01 AM, Shehjar Tikoo wrote:
> Hi All
> 
> The following thread discusses the behaviour when the client does not support v4:
> http://thread.gmane.org/gmane.linux.nfs/36928/
> 
> OTOH, when the server does not support v4, for eg. Gluster NFS server, where we support only v3, I believe v4 client will attempt to connect directly to port 2049 and receive connection failure errors on TCP. Does the current nfs client handle the situation where this results in a timeout for mount? We're hearing  a report of a timeout occurring on the RHEL6 client because the server does not have v4 support. Could someone please shed some light on how this behaviour is handled at present? Thanks
Here is the current logic as to what will cause a fall back:

    switch (errno) {
    case EPROTONOSUPPORT:
        /* A clear indication that the server or our
         * client does not support NFS version 4. */
        goto fall_back;
    case ENOENT:
        /* Legacy Linux servers don't export an NFS
         * version 4 pseudoroot. */
        goto fall_back;
    case EPERM:
        /* Linux servers prior to 2.6.25 may return
         * EPERM when NFS version 4 is not supported. */
        goto fall_back;
    default:
        return result;
    }

fall_back:
    return nfs_try_mount_v3v2(mi);

So in the case of the Gluster server, you are dropping into the
default case which is causing the time out.

In the above patch set, Mi patches the mount code 
to fall back on EINVAL which is the current return value from 
the kernel, when v4 is not configured. I'm not totally 
against doing something like this, but this is very touchy  
code since it could have negative effects on other legacy 
servers.

So I'm thinking Mi's kernel patch that cause the kernel
to return EPROTONOSUPPORT, which is the correct return
value, is probably the better way to go... 

With that said, to get this type of functionality into
already released distros, maybe the mount patch should be 
looked into since it much easier to back port and people 
are more will to take nfs-utils updates than kernel updates... 

So, if by chance, a well place bz is opened against an 
already released distro, someone would have to make that 
call... ;-) 

steved.
  


