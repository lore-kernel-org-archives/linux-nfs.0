Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932801Ab3CYUMm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 16:12:42 -0400
Message-ID: <5150AFB7.6010508@RedHat.com>
Date: Mon, 25 Mar 2013 16:12:39 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/11] NFSv4.1: Enable open-by-filehandle
References: <1363698463-3681-9-git-send-email-Trond.Myklebust@netapp.com> <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com> <20130319140901.GB7912@fieldses.org> <1363702570.7515.6.camel@leira.trondhjem.org> <20130319143236.GD7912@fieldses.org> <1363704100.7515.12.camel@leira.trondhjem.org> <20130319145035.GE7912@fieldses.org> <1363706205.7515.43.camel@leira.trondhjem.org> <20130319152304.GG7912@fieldses.org> <1363711037.7515.44.camel@leira.trondhjem.org> <20130321152516.GA28922@fieldses.org>
In-Reply-To: <20130321152516.GA28922@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 21/03/13 11:25, J. Bruce Fields wrote:
> On Tue, Mar 19, 2013 at 04:37:17PM +0000, Myklebust, Trond wrote:
>> On Tue, 2013-03-19 at 11:23 -0400, J. Bruce Fields wrote:
>>> On Tue, Mar 19, 2013 at 03:16:46PM +0000, Myklebust, Trond wrote:
>>>> On Tue, 2013-03-19 at 10:50 -0400, J. Bruce Fields wrote:
>>>>> On Tue, Mar 19, 2013 at 02:41:42PM +0000, Myklebust, Trond wrote:
>>>>>> On Tue, 2013-03-19 at 10:32 -0400, J. Bruce Fields wrote:
>>>>>>> (Sorry for the digression, I was just trying to decide whether I can get
>>>>>>> away with turning on 4.1 by default before implementing SP4_MACH_CRED or
>>>>>>> GSS on the backchannel....)
>>>>>>
>>>>>> If you don't, could you please at least offer up a module parameter that
>>>>>> allows me to do that? The current thing is a PITA, since it isn't
>>>>>> supported by any distro scripts, and it requires you to switch off the
>>>>>> server in order to change the version pseudofile contents.
>>>>>
>>>>> The module parameter on its own wouldn't help with that.
>>>>>
>>>>> We could probably fix the pseudofile interface to allow changing the
>>>>> version on the fly.
>>>>>
>>>>> My vague plan was to teach rpc.nfsd to read this (and other parameters)
>>>>> from a config file, so then it'd be "vi /etc/nfsd && service nfsd
>>>>> restart" or equivalent.
>>>>>
>>>>> So is the main thing you want a more convenient interface or a way to
>>>>> change it without rebooting?
>>>>
>>>> Basically, all I want is to enable 4.1 permanently on those servers that
>>>> I want to use for NFSv4.1 testing.
>>>>
>>>> An --enable-nfs-version option for rpc.nfsd that acts together with
>>>> --no-nfs-version as a convenient interface for /proc/fs/nfsd/versions
>>>> would work fine too. All distro configuration scripts that I'm aware of
>>>> allow you to specify optional arguments to rpc.nfsd.
>>>
>>> Right, got it.  Yes, that's on my todo list.
>>>
>>> (But, of course, patches welcomed if someone wants to beat me to it.)
>>
>> Here you go...
> 
> Looks fine to me.--b.
> 
>>
>> -- 
>> Trond Myklebust
>> Linux NFS client maintainer
>>
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
> 
>> From 3beebc45d59aa990cb57efbfb55b62f69182d40a Mon Sep 17 00:00:00 2001
>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Date: Tue, 19 Mar 2013 12:28:35 -0400
>> Subject: [PATCH] nfsd: Add support for the -V and --nfs-version optional
>>  arguments
>>
>> Add command line options to enable those NFS versions that are
>> currently disabled by default. We choose to use the options '-V'
>> and '--nfs-version' for compatibility with rpc.mountd.
>>
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

BTW, A good way to hide patch is to make it and attachment in one 
of the last emails of a fairly lengthy thread.... 8-)

Committed! 

steved.
  
>> ---
>>  support/include/nfs/nfs.h |  1 +
>>  utils/nfsd/nfsd.c         | 26 ++++++++++++++++++++++++--
>>  utils/nfsd/nfsd.man       |  9 ++++++++-
>>  3 files changed, 33 insertions(+), 3 deletions(-)
>>
>> diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
>> index 320880e..174c2dd 100644
>> --- a/support/include/nfs/nfs.h
>> +++ b/support/include/nfs/nfs.h
>> @@ -52,6 +52,7 @@ struct nfs_fh_old {
>>  #define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & NFSCTL_UDPBIT) 
>>  #define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & NFSCTL_TCPBIT) 
>>  
>> +#define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |= (1 << ((_v) - 1))) 
>>  #define NFSCTL_UDPSET(_cltbits)       ((_cltbits) |= NFSCTL_UDPBIT)
>>  #define NFSCTL_TCPSET(_cltbits)       ((_cltbits) |= NFSCTL_TCPBIT)
>>  
>> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
>> index 2a3f5cc..e87c0a9 100644
>> --- a/utils/nfsd/nfsd.c
>> +++ b/utils/nfsd/nfsd.c
>> @@ -38,6 +38,7 @@ static struct option longopts[] =
>>  	{ "host", 1, 0, 'H' },
>>  	{ "help", 0, 0, 'h' },
>>  	{ "no-nfs-version", 1, 0, 'N' },
>> +	{ "nfs-version", 1, 0, 'V' },
>>  	{ "no-tcp", 0, 0, 'T' },
>>  	{ "no-udp", 0, 0, 'U' },
>>  	{ "port", 1, 0, 'P' },
>> @@ -119,7 +120,7 @@ main(int argc, char **argv)
>>  	xlog_syslog(0);
>>  	xlog_stderr(1);
>>  
>> -	while ((c = getopt_long(argc, argv, "dH:hN:p:P:sTU", longopts, NULL)) != EOF) {
>> +	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTU", longopts, NULL)) != EOF) {
>>  		switch(c) {
>>  		case 'd':
>>  			xlog_config(D_ALL, 1);
>> @@ -175,6 +176,27 @@ main(int argc, char **argv)
>>  				exit(1);
>>  			}
>>  			break;
>> +		case 'V':
>> +			switch((c = strtol(optarg, &p, 0))) {
>> +			case 4:
>> +				if (*p == '.') {
>> +					int i = atoi(p+1);
>> +					if (i != 1) {
>> +						fprintf(stderr, "%s: unsupported minor version\n", optarg);
>> +						exit(1);
>> +					}
>> +					minorvers41 = 1;
>> +					break;
>> +				}
>> +			case 3:
>> +			case 2:
>> +				NFSCTL_VERSET(versbits, c);
>> +				break;
>> +			default:
>> +				fprintf(stderr, "%s: Unsupported version\n", optarg);
>> +				exit(1);
>> +			}
>> +			break;
>>  		case 's':
>>  			xlog_syslog(1);
>>  			xlog_stderr(0);
>> @@ -312,7 +334,7 @@ static void
>>  usage(const char *prog)
>>  {
>>  	fprintf(stderr, "Usage:\n"
>> -		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version ] [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] nrservs\n", 
>> +		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version] [-V|--nfs-version version] [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] nrservs\n", 
>>  		prog);
>>  	exit(2);
>>  }
>> diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
>> index 1cf9296..7de0867 100644
>> --- a/utils/nfsd/nfsd.man
>> +++ b/utils/nfsd/nfsd.man
>> @@ -47,7 +47,7 @@ This option can be used to request that
>>  .B rpc.nfsd
>>  does not offer certain versions of NFS. The current version of
>>  .B rpc.nfsd
>> -can support both NFS version 2,3 and the newer version 4.
>> +can support NFS versions 2,3,4 and the newer version 4.1.
>>  .TP
>>  .B \-s " or " \-\-syslog
>>  By default,
>> @@ -67,6 +67,13 @@ Disable
>>  .B rpc.nfsd
>>  from accepting UDP connections from clients.
>>  .TP
>> +.B \-V " or " \-\-nfs-version vers
>> +This option can be used to request that 
>> +.B rpc.nfsd
>> +offer certain versions of NFS. The current version of
>> +.B rpc.nfsd
>> +can support NFS versions 2,3,4 and the newer version 4.1.
>> +.TP
>>  .I nproc
>>  specify the number of NFS server threads. By default, just one
>>  thread is started. However, for optimum performance several threads
>> -- 
>> 1.8.1.4
>>
> 
