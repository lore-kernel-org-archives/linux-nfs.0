From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Mon, 19 Jan 2009 10:12:55 +1100
Message-ID: <4973B777.2000102@melbourne.sgi.com>
References: <4970B451.4080201@RedHat.com> <49711BDF.3010605@melbourne.sgi.com> <y0mmydpucww.fsf@ton.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	SystemTAP
	<public-systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "Frank Ch. Eigler" <fche@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:37721 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752982AbZARXNX (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Sun, 18 Jan 2009 18:13:23 -0500
In-Reply-To: <y0mmydpucww.fsf-vo4H8ooykKW2oG+2xah3EoGKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Frank Ch. Eigler wrote:
> Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org> writes:
>
>   
>> I have a patch which changes the definition of the dprintk() macro
>> (but *not* dprintk() callsites) to allow enabling and disabling
>> individual dprintk() statements through a /proc/ interface.  Would
>> you be interested in that?
>>     
>
> It would make more sense to me to turn dprintk's into trace_marks, 
Umm, ok.  Sorry to be so ignorant but where would I find the doc that
tells me about adding trace marks ?

> then
> use http://lkml.org/lkml/2008/12/30/297 to control transmission of the
> data to ftrace.
>
>   
The control interface seems a little primitive.  It seems like you can
only activate and deactivate single printks ? I don't see a way to e.g.
activate every trace make in a particular function, or in a particular
.c file.  I thought both of these were useful things to do, so I
implemented them.  Below is an extract from the doc that accompanies the
sgi-dprintk module.

The dprintk module has even more useful features:

 * Simple query language allows turning on and off dprintks by matching
   any combination of:

   - source filename
   - function name
   - line number (including ranges of line numbers)
   - module name
   - format string

 * Provides a /proc/dprintk which can be read to display the complete
   list of all dprintk()s known, to help guide you

 * The module is optional.  The NFS dprintk()s still work with the
   /proc/sys/sunrpc/ bitmasks.  The dprintk module can be loaded or
   unloaded at any time.

 * In addition to enabling the print, two other behaviours can be enabled:

  - printing a kernel stack trace
  - crashing the kernel, so that a dump can be taken

...

Viewing dprintk() Behaviour
===========================

You can view the currently configured behaviour of all the dprintk()s
in loaded modules by reading /proc/dprintk.  For example:

nullarbor:~ # cat /proc/dprintk
# filename:lineno [module]function flags format
/usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svc_rdma.c:323 [svcxprt_rdma]svc_rdma_cleanup - "SVCRDMA\040Module\040Removed,\040deregister\040RPC\040RDMA\040transport\012"
/usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svc_rdma.c:341 [svcxprt_rdma]svc_rdma_init - "\011max_inline\040\040\040\040\040\040\040:\040%d\012"
/usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svc_rdma.c:340 [svcxprt_rdma]svc_rdma_init - "\011sq_depth\040\040\040\040\040\040\040\040\040:\040%d\012"
/usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svc_rdma.c:338 [svcxprt_rdma]svc_rdma_init - "\011max_requests\040\040\040\040\040:\040%d\012"
...

Command Language Reference
==========================

At the lexical level, a command comprises a sequence of words separated
by whitespace characters.  Note that newlines are treated as word
separators and do *not* end a command or allow multiple commands to
be done together.  So these are all equivalent:

nullarbor:~ # echo -c 'file svcsock.c line 1603 +p' > /proc/dprintk
nullarbor:~ # echo -c '  file   svcsock.c     line  1603 +p  ' > /proc/dprintk
nullarbor:~ # echo -c 'file svcsock.c\nline 1603 +p' > /proc/dprintk
nullarbor:~ # echo -n 'file svcsock.c line 1603 +p' > /proc/dprintk

Commands are bounded by a write() system call.  If you want to do
multiple commands you need to do a separate "echo" for each, like:

nullarbor:~ # echo 'file svcsock.c line 1603 +p' > /proc/dprintk ;\
> echo 'file svcsock.c line 1563 +p' > /proc/dprintk

or even like:

nullarbor:~ # (
> echo 'file svcsock.c line 1603 +p' ;\
> echo 'file svcsock.c line 1563 +p' ;\
> ) > /proc/dprintk

At the syntactical level, a command comprises a sequence of match
specifications, followed by a flags change specification.

command ::= match-spec* flags-spec

The match-spec's are used to choose a subset of the known dprintk()
callsites to which to apply the flags-spec.  Think of them as a query
with implicit ANDs between each pair.  Note that an empty list of
match-specs is possible, but is not very useful because it will not
match any dprintk() callsites.

A match specification comprises a keyword, which controls the attribute
of the callsite to be compared, and a value to compare against.  Possible
keywords are:

match-spec ::= 'func' string |
               'file' string |
               'module' string |
               'format' string |
               'line' line-range

line-range ::= lineno |
               '-'lineno |
               lineno'-' |
               lineno'-'lineno
// Note: line-range cannot contain space, e.g.
// "1-30" is valid range but "1 - 30" is not.

lineno ::= unsigned-int

The meanings of each keyword are:

func
    The given string is compared against the function name
    of each callsite.  Example:

    func svc_tcp_accept

file
    The given string is compared against either the full
    pathname or the basename of the source file of each
    callsite.  Examples:

    file svcsock.c
    file /usr/src/packages/BUILD/sgi-enhancednfs-1.4/default/net/sunrpc/svcsock.c

module
    The given string is compared against the module name
    of each callsite.  The module name is the string as
    seen in "lsmod", i.e. without the directory or the .ko
    suffix and with '-' changed to '_'.  Examples:

    module sunrpc
    module nfsd

format
    The given string is searched for in the dprintk() format
    string.  Note that the string does not need to match the
    entire format, only some part.  Whitespace and other
    special characters can be escaped using C octal character
    escape \ooo notation, e.g. the space character is \040.
    Examples:

    format svcrdma:         // many of the NFS/RDMA server dprintks
    format readahead        // some dprintks in the readahead cache
    format nfsd:\040SETATTR // how to match a format with whitespace

line
    The given line number or range of line numbers is compared
    against the line number of each dprintk() callsite.  A single
    line number matches the callsite line number exactly.  A
    range of line numbers matches any callsite between the first
    and last line number inclusive.  An empty first number means
    the first line in the file, an empty line number means the
    last number in the file.  Examples:

    line 1603       // exactly line 1603
    line 1600-1605  // the six lines from line 1600 to line 1605
    line -1605      // the 1605 lines from line 1 to line 1605
    line 1600-      // all lines from line 1600 to the end of the file

The flags specification comprises a change operation followed
by one or more flag characters.  The change operation is one
of the characters:

-
    remove the given flags

+
    add the given flags

=
    set the flags to the given flags

The flags are:

p
    Causes a printk() message to be emitted to dmesg,
    i.e. the obvious semantic of a dprintk().

s
    Causes a kernel stack trace to be emitted to dmesg.
    The printk() is emitted first, even if the 'p' flag
    is not specified.

c
    Causes the kernel to panic using the kernel BUG()
    macro.  This will cause the machine to drop into KDB
    or take a kernel crash dump, according to how the
    machine has been configured.  The printk() is emitted
    first, even if the 'p' flag is not specified.

Note the regexp ^[-+=][scp]+$ matches a flags specification.
Note also that there is no convenient syntax to remove all
the flags at once, you need to use "-psc".

Examples
========

// enable the message at line 1603 of file svcsock.c
nullarbor:~ # echo -n 'file svcsock.c line 1603 +p' > /proc/dprintk

// enable all the messages in file svcsock.c
nullarbor:~ # echo -n 'file svcsock.c +p' > /proc/dprintk

// enable all the messages in file svcsock.c
nullarbor:~ # echo -n 'file svcsock.c +p' > /proc/dprintk

// enable all the messages in the NFS server module
nullarbor:~ # echo -n 'module nfsd +p' > /proc/dprintk

// enable all 12 messages in the function svc_process()
nullarbor:~ # echo -n 'func svc_process +p' > /proc/dprintk

// disable all 12 messages in the function svc_process()
nullarbor:~ # echo -n 'func svc_process -p' > /proc/dprintk

// print a stack trace on every upcall to rpc.mountd or rpc.idmapd
nullarbor:~ # echo -n 'format Want\040update,\040refage +s' > /proc/dprintk

// cause a kernel crash dump when an RPC call to an
// unknown RPC program number is received
nullarbor:~ # echo -n 'format unknown\040program +c' > /proc/dprintk



-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

