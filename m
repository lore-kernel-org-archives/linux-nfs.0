Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25252 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392Ab2KLU4Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 15:56:16 -0500
Message-ID: <50A16269.4060601@RedHat.com>
Date: Mon, 12 Nov 2012 15:56:09 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "David P. Quigley" <selinux@davequigley.com>,
        David Quigley <dpquigl@davequigley.com>, trond.myklebust@netapp.com,
        sds@tycho.nsa.gov, linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org
Subject: Re: Labeled NFS [v5]
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <20121112152335.GH30713@fieldses.org> <50A116F0.5050404@davequigley.com> <20121112160959.GK30713@fieldses.org>
In-Reply-To: <20121112160959.GK30713@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/11/12 11:09, J. Bruce Fields wrote:
> On Mon, Nov 12, 2012 at 10:34:08AM -0500, David P. Quigley wrote:
>> On 11/12/2012 10:23 AM, J. Bruce Fields wrote:
>>> On Mon, Nov 12, 2012 at 01:15:34AM -0500, David Quigley wrote:
>>>> The NFSv4 working group has finally accepted Labeled NFS as part of the NFSv4.2
>>>> specification and it has been decided that a reposting of the Labeled NFS code
>>>> for inclusion into mainline was a good idea. The patches have been rebased onto
>>>> v3.7-rc2 and have been tested against the SELinux testsuite with the only
>>>> failures being for features not supported by NFS.
>>> By the way, is there wireshark support anywhere for the labeled NFS
>>> protocol?
>>>
>>> --b.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> Unfortunately I never got a chance to add it. You can see the label
>> pretty clearly in wireshark but it comes up as an unknown attribute
>> in the fattr decomposition. If someone knows how to do it I'd be
>> glad to help.
> 
> It's usually not too hard: last time I needed something I did a
> 
> 	git clone http://code.wireshark.org/git/wireshark
> 
> then grepped through epan/dissectors/packet-nfs.c for something similar
> to imitate.  It wa easy to build and run the result from the build
> directory.  Then I submitted a patch following:
> 
> 	http://www.wireshark.org/docs/wsdg_html_chunked/ChSrcContribute.html#ChSrcSend
> 
> and the response was quick and helpful.
> 
> (But yeah I don't have time to volunteer right now either.)
Maybe I could take a look into helping out... If you guys can point
me a some binary traces or a boot-able kernel I can take a crack
at coming up with some dissectors... 

Connectathon is 3.5 months out so hopefully we can come up with
something by then.... 

steved.

