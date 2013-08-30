Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tuna.sandelman.ca ([209.87.252.184]:53163 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab3H3S1S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Aug 2013 14:27:18 -0400
From: Michael Richardson <mcr@sandelman.ca>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
cc: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Jan Kara <jack@suse.cz>,
        "user-mode-linux-devel@lists.sourceforge.net"
	<user-mode-linux-devel@lists.sourceforge.net>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-ext4@vger.kernel.org
Subject: Re: [uml-devel] Issues with a rather unusual configured NFS server
In-Reply-To: <CAFLxGvyK5+nB9TgW1uPho9KGwQrWQHx=wEpj+o-mZcN92bWAOg@mail.gmail.com>
References: <52075E01.7030506@gmx.de> <20130812143640.GF4596@quack.suse.cz> <20130813215313.GH17781@fieldses.org> <20130827180655.GE14809@fieldses.org> <521E318C.7040401@gmx.de> <CAFLxGvyK5+nB9TgW1uPho9KGwQrWQHx=wEpj+o-mZcN92bWAOg@mail.gmail.com>
Date: Fri, 30 Aug 2013 14:27:08 -0400
Message-ID: <29555.1377887228@sandelman.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


richard -rw- weinberger <richard.weinberger@gmail.com> wrote:
    >>>> Thanks for the report.  I think I see the problem--after this commit
    >>>> nfs4_set_delegation() failures result in nfs4_put_delegation being
    >>>> called, but nfs4_put_delegation doesn't free the nfs4_file that has
    >>>> already been set by alloc_init_deleg().
    >>>>
    >>>> Let me think about how to fix that....
    >>>
    >>> Sorry for the slow response--can you check whether this fixes the
    >>> problem?
    >>>
    >> Yes.
    >>
    >> With the attached patch the problem can't be reproduced any longer
    >> with the prepared test case and current git kernels.

    > BTW: Is nobody else fuzz testing NFS?  Or are these bugs just more
    > likely to hit on UML?  This is not the first NFS issue found by Toralf
    > using UML and Trinity.

Kernel thread scheduling is likely very different on UML than other
architectures.

My guess is that there could well be be gaps where no kernel thread is
scheduled (because another process is running), followed by resumption of a
thread other than the one which would have been resumed on other
virtualization.

--
]               Never tell me the odds!                 | ipv6 mesh networks [
]   Michael Richardson, Sandelman Software Works        | network architect  [
]     mcr@sandelman.ca  http://www.sandelman.ca/        |   ruby on rails    [

