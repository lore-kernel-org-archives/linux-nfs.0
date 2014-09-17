Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754510AbaIQM7b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2014 08:59:31 -0400
Message-ID: <541985AF.5040905@RedHat.com>
Date: Wed, 17 Sep 2014 08:59:27 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Fred Isaman <iisaman@netapp.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: Re: nfs4_state_manager() vs. nfs_server_remove_lists()
References: <53D7EA62.3070204@RedHat.com>	<CAHQdGtQ2DU4GnMXy=n9JQzUhGkEC=+UEM8NVm=MviBt0+RJzBA@mail.gmail.com>	<53D806C1.9030206@RedHat.com>	<CAHQdGtRkbjKXvzBSQvEyrnOvmiWSrwHMe+9eiEvvDz5Pm6WGNA@mail.gmail.com>	<CADnza45-ytG-0GcfS3Q0SczekP9M+F9z5EJA0dMsbhD3V=d2Gg@mail.gmail.com> <CAHQdGtToAxvW2CWibgPyRA9phHw+sVmyO0kCCS-41DWs2OcTbg@mail.gmail.com>
In-Reply-To: <CAHQdGtToAxvW2CWibgPyRA9phHw+sVmyO0kCCS-41DWs2OcTbg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 09/16/2014 03:28 PM, Trond Myklebust wrote:
> On Tue, Sep 16, 2014 at 2:51 PM, Fred Isaman <iisaman@netapp.com> wrote:
>> > Was a patch ever submitted for this?  I'm seeing something similar but can't
>> > find the fix upstream.
> As far as I can tell, the answer is no. If you are seeing the bug,
> then could you please post the discussed fix?

It looks like I dropped the ball... I too am see this problem
and can not find the posted patch... Working on it.... 

steved.
