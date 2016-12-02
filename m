Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36784 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751040AbcLBRdy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2016 12:33:54 -0500
Received: by mail-io0-f180.google.com with SMTP id m5so355772442ioe.3
        for <linux-nfs@vger.kernel.org>; Fri, 02 Dec 2016 09:33:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CABW3MLc_7K_u_vHxD+BZ2ZQF1r96CjbokhVVzLmKAdK1MRoZ_g@mail.gmail.com>
References: <CABW3MLd5Bo-xBtLqtB4e-pD2hCYAuRaBBsqBFTiws5-HohjPTw@mail.gmail.com>
 <87h96n6vbl.fsf@notabene.neil.brown.name> <BD0BB270-C6F4-4129-8D21-A3E9A6970459@primarydata.com>
 <CABW3MLc_7K_u_vHxD+BZ2ZQF1r96CjbokhVVzLmKAdK1MRoZ_g@mail.gmail.com>
From: Joachim Banzhaf <joachim.banzhaf@googlemail.com>
Date: Fri, 2 Dec 2016 18:33:37 +0100
Message-ID: <CABW3MLeYOrFnP9Gwi8EbN7bNyzx31k=ObH4TuFuki_14YNyqmw@mail.gmail.com>
Subject: Re: rpcbind allowed port range on linux
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: "joachim.banzhaf" <joachim.banzhaf@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mystery solved:

The ip_local_port_range used by rpc services (and others) is set via
/etc/sysctl.conf during boot, and the application that needs ports
from that range sets ip_local_reserved_ports, but later in the boot
process. Too late. I need to solve this there.

Thanks for the support, you put me on the right track.

BR,
Joachim

2016-12-02 9:32 GMT+01:00 Joachim Banzhaf <joachim.banzhaf@googlemail.com>:
> Hi Neil and Trond, thanks for the infos. Already helped a lot.
>
> My primary goal is not to pin lockd to a specific port.
> I want to prevent any ip service that does not ask for a specific port
> to use ports I know are needed later for something else.
>
> I thought, the mechanism is (sorry, had a cut&paste error here) by
> defining range /proc/sys/net/ipv4/ip_local_port_range minus ports or
> ranges in /proc/sys/net/ipv4/ip_local_reserved_ports (as described
> here: http://lxr.free-electrons.com/source/Documentation/networking/ip-sysctl.txt#L809).
>
> I wasn't sure, this mechanism is used here, but Neil, you already
> confirmed at least part 1, and that is what happened. Just the
> exclusion via /proc/sys/net/ipv4/ip_local_reserved_ports has not
> worked.
> To be specific, the ip_local_port_range is "40000   65299", and
> ip_local_reserved_ports includes, among many others, 50000-50628 and
> the port to protect but still picked for lockd was 50213.
>
> Unfortunately, choosing another ip_local_port_range outside 50213 is
> not possible, because there is no single range left that is big enough
> (and there are other ports to protect like this one).
>
> So, either ip_local_reserved_ports is not used (although I think it
> should) or it is used but too long (at least sysctl used in SLES 12
> has a bug: it cannot display the whole list) or the list is not
> defined at the time lockd gets its port (I did not find where this is
> defined, it is not in /etc/sysctl.conf, like ip_local_port_range).
>
> BR,
> Joachim
