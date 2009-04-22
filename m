From: Petr Vandrovec <petr@vmware.com>
Subject: Re: [Bug 13034] printk in xs_tcp_setup_socket needs rate limit ...
 and delay
Date: Wed, 22 Apr 2009 15:22:14 -0700
Message-ID: <49EF9896.2000301@vmware.com>
References: <bug-13034-104@http.bugzilla.kernel.org/>	 <200904222049.n3MKnxZi019947@demeter.kernel.org> <1240433936.9197.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org"
	<bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org>,
	Petr Vandrovec <petr@vandrovec.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	"khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org" <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:56291 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755473AbZDVWWP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 18:22:15 -0400
In-Reply-To: <1240433936.9197.9.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> (Switching to bugzilla email interface, and ccing linux-nfs)
> 
> On Wed, 2009-04-22 at 20:49 +0000, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
> wrote:
>> http://bugzilla.kernel.org/show_bug.cgi?id=13034
>>
>>
>>
>>
>>
>> --- Comment #12 from Petr Vandrovec <petr@vandrovec.name>  2009-04-22 20:49:58 ---
>> Unfortunately I have no access to the server (they are some NetApp and EMC
>> storage devices maintained by company IT).
>>
>> It seems that they are all configured same way, so after mount they start
>> timing out connections all at the same moment (after 10 minutes since mount, or
>> something like that), and netstat above is captured when I run 'df' after
>> connections moved from established to time_wait on client side.  That TIME_WAIT
>> disappear after 60 seconds, as expected.
> 
> So these connections are basically timing out because the systems are
> idle? (FYI: the NFS convention is that clients are supposed to close the
> TCP connection if it has been idle for 5 minutes, whereas the servers
> usually close it if the client has been idle for 6 minutes)...

Yes, they are timing out because system is idle.  It seems that it 
behaves way it should - it is client who closes them, 5 minutes after I 
run 'df':

$ savedq=-1; df > /dev/null; while true; do q="`netstat -atn | grep 2049 
| grep TIME_WAIT | wc -l`"; if [ "$q" != "$savedq" ]; then echo -n "$q 
"; date; savedq="$q"; fi; sleep 1; done
0 Wed Apr 22 14:59:10 PDT 2009
28 Wed Apr 22 15:04:10 PDT 2009
0 Wed Apr 22 15:05:08 PDT 2009

So as far as I can tell with patch everything works as expected.
							Petr
