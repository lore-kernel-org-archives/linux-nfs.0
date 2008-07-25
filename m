From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: incorrect entries in /etc/netconfig
Date: Fri, 25 Jul 2008 14:32:44 -0400
Message-ID: <777E985E-D123-4A74-9770-DB8DDA4DADBA@oracle.com>
References: <BE9551A6-D4EB-4A8A-9D26-18C4722CF136@oracle.com> <4873A681.5080409@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:32406 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbYGYSdR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2008 14:33:17 -0400
In-Reply-To: <4873A681.5080409-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul 8, 2008, at 1:40 PM, Steve Dickson wrote:
> Sorry for taking soo long to address this...
>
> Chuck Lever wrote:
>> Hi Steve-
>>
>> I'm trying out setconfigent() and friends from the new libtirpc.
>>
>> It looks like the entries in the stock /etc/netconfig on Fedora are
>> incorrect compared with Solaris.  My Fedora 8 system has this:
>>
>> udp        tpi_clts      v     inet     udp     -       -
>> tcp        tpi_cots_ord  v     inet     tcp     -       -
>> udp6       tpi_clts      -     inet6    udp6     -       -
>> tcp6       tpi_cots_ord  -     inet6    tcp6    -       -
>>
>> but my OpenSolaris 2008.5 system has this:
>>
>> udp6       tpi_clts      v     inet6   udp    /dev/udp6       -
>> tcp6       tpi_cots_ord  v     inet6   tcp    /dev/tcp6       -
>> udp        tpi_clts      v     inet    udp    /dev/udp        -
>> tcp        tpi_cots_ord  v     inet    tcp    /dev/tcp        -
>>
>> Note the contents of the fifth field in each row.  The Fedora  
>> netconfig
>> has "udp6" and "tcp6" as the protonames, which I think is incorrect.
>> These should be "udp" and "tcp".  Only the netids (the first field)
>> should have the extra "6" suffix.  The protocol names should always  
>> be
>> "udp" or "tcp", no matter which address family is used.
>>
>> Can you fix this up in the libtirpc package?
> It is in later releases... to be honest I'm not sure how
> it got that way.. It did not seem to be broken in the
> stock F8 (libtirpc-0.1.7-12), F9 or rawhide packages

FYI: I just hit this again on a fairly fresh F9 install.

I wonder if installing libtirpc-devel breaks /etc/netconfig?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
