From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: Unable to kill processes in D-state
Date: Mon, 7 Oct 2002 10:24:43 -0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200210070731.g977VAp17211@Port.imtp.ilyichevsk.odessa.ua>
References: <1033841462.1247.3716.camel@phantasy> <20021006164228.GB17170@vagabond> <20021006170932.GA23134@stud.ntnu.no>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org, Thomas Lang?s <tlan@stud.ntnu.no>
In-Reply-To: <20021006170932.GA23134@stud.ntnu.no>
List-ID: <nfs.lists.sourceforge.net>

On 6 October 2002 15:09, Thomas Lang?s wrote:
> Jan Hudec:
> > If the shares were successfuly reloaded, then the processes should
> > wake up. If they don't, it's a bug in NFS.
>
> They never wake up, and it happens every time.
>
> > Try to reproduce it (ie. reboot some machine, let it start
> > everything and then restart the autofsd and see if processes lock
> > up) and then talk to NFS maintainers about that.
>
> As I said above, it happens every time we encounter this, ie. it's a
> bug that easy to reproduce (since I added nfs@lists.sourceforge.net
> to the CC-list, I'm going to write some of what's already said in
> this thread).
>
> Problem:
> Processes entering D-state is unkillable. We have a problem with this
> everytime we restart autofs (which automounts quite a few NFS-shares
> on campus), ie. on our samba-boxes smbd hangs forever after this
> (in D-state). Samba still works, it's just that all the D-state
> processes is unkillable and will remain that way untill we reboot the
> computer. Every D-state process increases the load on the machine,
> and one of our 2-CPU intel-boxes currently remains at 430 (which
> extremly high for such a box).
>
> Solution:
> ? :)

Please provide info about:
* automounter startup options
* automounter configuration file(s)
* client/server kernel version and .config
* ksymoopsed SysRq-T dump of a couple of hung processes
  (no, not all processes! please select 2-5 hung processes _only_
  before feeding dump to ksymoops :-)
--
vda
