Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:56581
        "EHLO osg.samsung.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751676AbcKFMYZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Nov 2016 07:24:25 -0500
Message-ID: <581F20F4.2040304@osg.samsung.com>
Date: Sun, 06 Nov 2016 12:24:20 +0000
From: Luis de Bethencourt <luisbg@osg.samsung.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.com>, linux-fsdevel@vger.kernel.org
CC: Richard Weinberger <richard@nod.at>, linux-nfs@vger.kernel.org
Subject: Re: When is export_operations.get_parent triggered?
References: <581DD7B0.8080906@osg.samsung.com> <8760o1pose.fsf@notabene.neil.brown.name>
In-Reply-To: <8760o1pose.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/11/16 22:03, NeilBrown wrote:
> On Sat, Nov 05 2016, Luis de Bethencourt wrote:
> 
>> Hi all,
>>
>> I recently played with adding the basics to make befs exportable via NFS [0].
>>
>> I want to implement the get_parent member of the export_operations struct as
>> well, but I can't seem to trigger this member being called. I have implemented
>> a solution which I feel is wrong [1], but want to be able to test it before
>> moving forward.
>>
>> When is this member triggered? Any advice?
> 
> This is required when a filehandle for a directory arrives, but the
> directory is not in the dcache.
> NFSD needs to find dentries for the directory, the parent, the
> grandparent etc all the way up to the root.
> 
> The simplest way to trigger this is to mount the filesystem onto a
> different machine, 'cd' into a fairly deep directory, then reboot the
> server (or unexport, unmount, remount, re-export).
> Now 'ls -l' on the client.  That should trigger calls to ->get_parent.
> 
> ->get_parent() is a log like performing a lookup of "..".
> 
> NeilBrown
> 

Nice!

This makes a lot of sense. I just rebooted the server and saw the get_parent
being called. Before I was mistakenly trying without a reboot, but thanks to your
explanation now understand this better, the directory was still in the dcache and
it was using this instead.

Thank you Neil,
Luis
