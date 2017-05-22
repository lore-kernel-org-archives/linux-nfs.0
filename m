Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33693 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932968AbdEVROU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 13:14:20 -0400
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
To: James Bottomley <James.Bottomley@HansenPartnership.com>,
        David Howells <dhowells@redhat.com>, trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Linux Containers <containers@lists.linux-foundation.org>,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        ebiederm@xmission.com
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
 <1495472039.2757.19.camel@HansenPartnership.com>
From: Aleksa Sarai <asarai@suse.de>
Message-ID: <f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de>
Date: Tue, 23 May 2017 03:14:00 +1000
MIME-Version: 1.0
In-Reply-To: <1495472039.2757.19.camel@HansenPartnership.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> The reason I think this is necessary is that the kernel has no idea
>> how to direct upcalls to what userspace considers to be a container -
>> current Linux practice appears to make a "container" just an
>> arbitrarily chosen junction of namespaces, control groups and files,
>> which may be changed individually within the "container".

Just want to point out that if the kernel APIs for containers massively 
change, then the OCI will have to completely rework how we describe 
containers (and so will all existing runtimes).

Not to mention that while I don't like how hard it is (from a runtime 
perspective) to actually set up a container securely, there are 
undoubtedly benefits to having namespaces split out. The network 
namespace being separate means that in certain contexts you actually 
don't want to create a new network namespace when creating a container.

I had some ideas about how you could implement bridging in userspace (as 
an unprivileged user, for rootless containers) but if you can't join 
namespaces individually then such a setup is not practically possible.

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
